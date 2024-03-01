$env.comma_scope = {|_|{
    created: '2024-02-20{2}13:21:43'
    computed: {$_.computed:{|a, s| $'($s.created)($a)' }}
    log_args: {$_.filter:{|a, s| do $_.tips 'received arguments' $a }}
}}

$env.comma = {|_|{
    created: {|a, s| $s.computed }
    inspect: {|a, s| {index: $_, scope: $s, args: $a} | table -e }
    vscode-tasks: {
        $_.action: {
            mkdir .vscode
            ', --vscode -j' | do $_.batch ',.nu' | save -f .vscode/tasks.json
        }
        $_.desc: "generate .vscode/tasks.json"
        $_.watch: { glob: ',.nu' }
    }
    diff: {
        docker-entrypoint: {
            diff ...[
                -u
                docker-entrypoint.sh.origin
                docker-entrypoint.sh
            ] | save -f docker-entrypoint.sh.diff
        }
    }
    test: {
        $_.a: {|a,s|
            mut args = [
                --rm --name=test-pg
                -e POSTGRES_USER=foo
                -e POSTGRES_PASSWORD=foo
                -e POSTGRES_DB=foo
                -p 15432:5432
                -v $"($_.wd)/docker-entrypoint.sh:/usr/local/bin/docker-entrypoint.sh"
            ]
            if 'cron' in $a { $args ++= [[-e PGCONF_CRON__DATABASE_NAME="'cdc'"]] }
            if 'ferret' in $a { $args ++= [[
                -e FERRET_PORT=5000
                -p 5000:5000
            ]] }
            if 'tweak' in $a { $args ++= [[
                -e PGCONF_SHARED_BUFFERS=4GB
                -e PGCONF_WORK_MEM=32MB
                -e PGCONF_MAX_CONNECTIONS=200
            ]] }
            if 'pgcat' in $a { $args ++= [[
                -e 'PGCAT_CONF=/pgcat.toml'
                -v $"($_.wd)/pgcat.toml:/pgcat.toml"
                -p 6432:6432
            ]] }
            if 'mem' in $a {
                if 'temp' in $a {
                    $args ++= [[-e "POSTGRES_MAX_MEMORY_USAGE=16000,32,32"]]
                } else {
                    $args ++= [[-e "POSTGRES_MAX_MEMORY_USAGE=16000,32"]]
                }
            }
            pp $env.docker-cli run ...$args fj0rd/0x:pg
        }
        $_.c: {[
            cron
            ferret
            tweak
            mem
            pgcat
            temp
        ]}
    }
    calc_mem: {|a,s|
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
    pgcat: {
        pp $env.docker-cli run ...[
            -d --name pgcat
            --restart=always
            # --privileged
            # '--security-opt="seccomp=unconfined"'
            -p 6432:6432
            -v $"($_.wd)/pgcat.toml:/etc/pgcat/pgcat.toml"
            ghcr.io/postgresml/pgcat:latest
        ]
    }

    docker-file: {
        $_.a: {|a,s|
            ^$env.docker-cli exec test-pg cat $a.0
        }
        $_.c: {
            [
                '/var/lib/postgresql/data/usr.conf'
                '/var/log/postgresql/pgcat.log'
            ]
        }
    }
    .: {
        reload: {
            $_.action: {|a,s|
                let act = $a | str join ' '
                $', ($act)' | do $_.batch ',.nu'
            }
            $_.watch: { glob: ",.nu", clear: true }
            $_.completion: {|a,s|
                , -c ...$a
            }
            $_.desc: "reload ,.nu"
        }
    }
}}
