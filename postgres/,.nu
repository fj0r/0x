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
                -e POSTGRES_PASSWORD=test
                -e POSTGRES_DB=test
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
            if 'mem' in $a {
                if 'temp' in $a {
                    $args ++= [[-e "POSTGRES_MAX_MEMORY_USAGE=16000,32,32"]]
                } else {
                    $args ++= [[-e "POSTGRES_MAX_MEMORY_USAGE=16000,32"]]
                }
            }
            pp $env.docker-cli run ...$args fj0rd/0x:pg16
        }
        $_.c: {[
            cron
            ferret
            tweak
            mem
            temp
        ]}
    }
    usr.conf: {
        ^$env.docker-cli exec test-pg cat /var/lib/postgresql/data/usr.conf
    }
    dev: {
        comma: {
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
