$env.comma_scope = {|_|{
    created: '2024-02-20{2}13:21:43'
    computed: {$_.computed:{|a, s| $'($s.created)($a)' }}
}}

$env.comma = {}

'pg' | comma val null {
    db: foo
    user: foo
    passwd: foo
}

'rt' | comma val null {
    container: test-pg
    dir: pg16
}

'docker-entrypoint fetch'
| comma fun {
    curl -sSLo docker-entrypoint.sh.origin https://raw.githubusercontent.com/docker-library/postgres/master/16/bookworm/docker-entrypoint.sh
}

'docker-entrypoint patch'
| comma fun {
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
    | range 1..
    | each {|x| $o | range $x.0..($x.1 - 1) | get item | str join (char newline) }

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

'docker-entrypoint diff'
| comma fun {
    diff ...[
        -u
        docker-entrypoint.sh.origin
        docker-entrypoint.sh
    ] | save -f docker-entrypoint.sh.diff
}

'test'
| comma fun {|a,s,_|
    mut args = [
        --rm $"--name=($s.rt.container)"
        -e $"POSTGRES_USER=($s.pg.user)"
        -e $"POSTGRES_DB=($s.pg.db)"
        -e $"POSTGRES_PASSWORD=($s.pg.passwd)"
        -p 15432:5432
        -p 5433:5433
        -v $"($_.wd)/docker-entrypoint.sh:/usr/local/bin/docker-entrypoint.sh"
    ]
    if 'readyset' in $a { $args ++= [-e READYSET_MEMORY_LIMIT=0 ] }
    if 'cron' in $a { $args ++= [-e $"PGCONF_CRON__DATABASE_NAME='($s.pg.db)'"] }
    if 'base' in $a { $args ++= [-e "PGCONF_SHARED_PRELOAD_LIBRARIES='pg_stat_statements,pg_cron,pg_search,pg_analytics'"] }
    if 'ferret' in $a { $args ++= [-e FERRET_PORT=5000 -p 5000:5000] }
    if 'tweak' in $a { $args ++= [
        -e PGCONF_SHARED_BUFFERS=4GB
        -e PGCONF_WORK_MEM=32MB
        -e PGCONF_MAX_CONNECTIONS=200
   ] }
    if 'pgcat' in $a { $args ++= [
        -e 'PGCAT_CONF=/pgcat.toml'
        -v $"($_.wd)/pgcat.toml:/pgcat.toml"
        -p 6432:6432
   ] }
    if 'mem' in $a {
        if 'temp' in $a {
            $args ++= [-e "POSTGRES_MAX_MEMORY_USAGE=16000,32,32"]
        } else {
            $args ++= [-e "POSTGRES_MAX_MEMORY_USAGE=16000,32"]
        }
    }
    pp $env.docker-cli run ...$args fj0rd/0x:pg
} {
    cmp: {[
        base
        readyset
        cron
        ferret
        tweak
        mem
        pgcat
        temp
    ]}
}

'backup'
| comma fun {|a,s|
    sudo $env.docker-cli ...[
        exec $s.rt.container
        bash -c
        $'pg_dumpall -U ($s.pg.user) > /backup/($s.pg.db).pg.sql'
    ]
    sudo chown $env.USER -R backup/
}

'restore'
| comma fun {|a,s,_|
    pp $env.docker-cli rm -f $s.rt.container
    sudo rm -rf $"($s.rt.dir)/"
    mkdir $s.rt.dir
    pp $env.docker-cli run ...[
        -d --restart=always
        -v $"($_.wd)/($s.rt.dir):/var/lib/postgresql/data"
        -v $"($_.wd)/backup:/backup"
        -e $"POSTGRES_DB=($s.pg.db)"
        -e $"POSTGRES_USER=($s.pg.user)"
        -e $"POSTGRES_PASSWORD=($s.pg.passwd)"
        --security-opt apparmor=unconfined
        --name $s.rt.container
        postgres:16
    ]
    wait-cmd -t 'wait postgresql' {
        sudo $env.docker-cli ...[
            exec $s.rt.container
            bash -c
            $'pg_isready -U ($s.pg.user)'
        ]
    }
    sudo $env.docker-cli ...[
        exec $s.rt.container
        bash -c
        $'cat /backup/($s.pg.db).pg.sql | psql -U ($s.pg.user)'
    ]
}

'calc_mem'
| comma fun {|a,s,_|
    let fn = 'pg_calc_mem'
    let f = $'/tmp/pg_calc_mem.bash'
    mut st = false
    mut bd = []
    for i in (cat $"($_.wd)/docker-entrypoint.sh" | lines) {
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
    bash $f $a.0
}

'pgcat'
| comma fun {|a,s,_|
    pp $env.docker-cli run ...[
        -d --name pgcat
        --restart=always
        --privileged
        --security-opt apparmor=unconfined
        -p 6432:6432
        -v $"($_.wd)/pgcat.toml:/etc/pgcat/pgcat.toml"
        ghcr.io/postgresml/pgcat:latest
    ]
}

'docker file'
| comma fun {|a,s|
    ^$env.docker-cli exec test-pg cat $a.0
} {
    c: {
        [
            '/var/lib/postgresql/data/usr.conf'
            '/var/log/postgresql/pgcat.log'
        ]
    }
}

'dev reload'
| comma fun {|a,s|
    let act = $a | str join ' '
    $', ($act)' | batch ',.nu'
} {
    watch: { glob: ",.nu", clear: true }
    completion: {|a,s|
        , -c ...$a
    }
    desc: "reload ,.nu"
}

'dev vscode-tasks'
| comma fun {
    mkdir .vscode
    ', --vscode -j' | batch ',.nu' | save -f .vscode/tasks.json
} {
    desc: "generate .vscode/tasks.json"
    watch: { glob: ',.nu' }
}

'dev inspect'
| comma fun {|a,s,_| {index: $_, scope: $s, args: $a} | table -e }

