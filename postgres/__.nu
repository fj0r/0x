export def 'docker-entrypoint fetch' [] {
    curl -sSLo docker-entrypoint.sh.origin https://raw.githubusercontent.com/docker-library/postgres/master/17/bookworm/docker-entrypoint.sh
}

export def 'docker-entrypoint patch' [] {
    let o = open docker-entrypoint.sh.origin | lines | enumerate
    let m = {
        main: {
            pattern: '_main()'
        }
        init: {
            pattern: 'docker_verify_minimum_env'
        }
        user: {
            pattern: 'pg_setup_hba_conf "$@"'
            offset: 1
        }
        hook: {
            pattern: 'exec "$@"'
        }
    }
    let s = $m
    | items {|k,v|
        let offset = $v.offset? | default 0
        $o
        | filter {|x| $x.item | str contains $v.pattern }
        | last
        | get 'index'
        | $in + $offset
    }
    | append ($o | last | get 'index' | $in + 1)
    | reduce -f [[0,0]] {|i,a|
        let x = $a | last | last
        [...$a, [$x, $i]]
    }
    | slice 1..
    | each {|x| $o | slice $x.0..($x.1 - 1) | get item | str join (char newline) }

    $m | transpose k v
    | each {|x|
        open $"docker-entrypoint.sh.d/($x.k)"
        | $"###{{{ ($x.k)(char newline)($in)(char newline)###}}}"
    }
    | append ''
    | zip $s
    | reduce -f [] {|i,a|
        $a | append $i.1 | append $i.0
    }
    | str join (char newline)
    | save -f docker-entrypoint.sh
    chmod +x docker-entrypoint.sh
}

export def 'docker-entrypoint diff' [] {
    diff ...[
        -u
        docker-entrypoint.sh.origin
        docker-entrypoint.sh
    ] | save -f docker-entrypoint.sh.diff
}

def cmpl-test [] {
    [
        base
        readyset
        cron
        ferret
        tweak
        mem
        pgcat
        temp
    ]
}

export def 'test' [...a:string@cmpl-test] {
    mut args = [
        --rm $"--name=($env.rt.container)"
        -e $"POSTGRES_USER=($env.pg.user)"
        -e $"POSTGRES_DB=($env.pg.db)"
        -e $"POSTGRES_PASSWORD=($env.pg.passwd)"
        -p 15432:5432
        -p 5433:5433
        -v $"($env.PWD)/docker-entrypoint.sh:/usr/local/bin/docker-entrypoint.sh"
    ]
    if 'readyset' in $a { $args ++= [-e READYSET_MEMORY_LIMIT=0 ] }
    if 'cron' in $a { $args ++= [-e $"PGCONF_CRON__DATABASE_NAME='($env.pg.db)'"] }
    if 'base' in $a { $args ++= [-e "PGCONF_SHARED_PRELOAD_LIBRARIES='pg_stat_statements,pg_cron,pg_search,citus,timescaledb'"] }
    if 'ferret' in $a { $args ++= [-e FERRET_PORT=5000 -p 5000:5000] }
    if 'tweak' in $a { $args ++= [
        -e PGCONF_SHARED_BUFFERS=4GB
        -e PGCONF_WORK_MEM=32MB
        -e PGCONF_MAX_CONNECTIONS=200
   ] }
    if 'pgcat' in $a { $args ++= [
        -e 'PGCAT_CONF=/pgcat.toml'
        -v $"($env.PWD)/pgcat.toml:/pgcat.toml"
        -p 6432:6432
   ] }
    if 'mem' in $a {
        if 'temp' in $a {
            $args ++= [-e "POSTGRES_MAX_MEMORY_USAGE=16000,32,32"]
        } else {
            $args ++= [-e "POSTGRES_MAX_MEMORY_USAGE=16000,32"]
        }
    }
    pp $env.CONTCTL run ...$args 'ghcr.lizzie.fun/fj0r/0x:pg17'
}

export def 'backup' [] {
    sudo $env.CONTCTL ...[
        exec $env.rt.container
        bash -c
        $'pg_dumpall -U ($env.pg.user) > /backup/($env.pg.db).pg.sql'
    ]
    sudo chown $env.USER -R backup/
}

export def 'restore' [] {
    pp $env.CONTCTL rm -f $env.rt.container
    sudo rm -rf $"($env.rt.dir)/"
    mkdir $env.rt.dir
    pp $env.CONTCTL run ...[
        -d --restart=always
        -v $"($env.PWD)/($env.rt.dir):/var/lib/postgresql/data"
        -v $"($env.PWD)/backup:/backup"
        -e $"POSTGRES_DB=($env.pg.db)"
        -e $"POSTGRES_USER=($env.pg.user)"
        -e $"POSTGRES_PASSWORD=($env.pg.passwd)"
        --security-opt apparmor=unconfined
        --name $env.rt.container
        postgres:16
    ]
    wait-cmd -t 'wait postgresql' {
        sudo $env.CONTCTL ...[
            exec $env.rt.container
            bash -c
            $'pg_isready -U ($env.pg.user)'
        ]
    }
    sudo $env.CONTCTL ...[
        exec $env.rt.container
        bash -c
        $'cat /backup/($env.pg.db).pg.sql | psql -U ($env.pg.user)'
    ]
}

export def 'calc_mem' [a] {
    let fn = 'pg_calc_mem'
    let f = $'/tmp/pg_calc_mem.bash'
    mut st = false
    mut bd = []
    for i in (cat $"($env.PWD)/docker-entrypoint.sh" | lines) {
        if ($i | str starts-with $fn) {
            $st = true
        }
        if $st {
            $bd ++= $i
        }
        if ($i | str starts-with '}') {
            $st = false
        }
    }
    $bd
    | append "pg_calc_mem $1"
    | str join (char newline) | save -f $f
    bash $f $a
}

export def 'pgcat' [] {
    pp $env.CONTCTL run ...[
        -d --name pgcat
        --restart=always
        --privileged
        --security-opt apparmor=unconfined
        -p 6432:6432
        -v $"($env.PWD)/pgcat.toml:/etc/pgcat/pgcat.toml"
        ghcr.io/postgresml/pgcat:latest
    ]
}

