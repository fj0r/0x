$env.comma_scope = {|_|{
    created: '2023-12-28{4}09:51:01'
    computed: {$_.computed:{|a, s| $'($s.created)($a)' }}
}}

$env.comma = {|_|{
    created: {|a, s| $s.computed }
    inspect: {|a, s| {index: $_, scope: $s, args: $a} | table -e }
    vscode-tasks: {
        $_.a: {
            mkdir .vscode
            '--vscode -j' | do $_.batch ',.nu' | save -f .vscode/tasks.json
        }
        $_.d: "generate .vscode/tasks.json"
        $_.w: { glob: ',.nu' }
    }
    srv: {
        $_.action: {|a,s|
            let cfgs = [
                default.json
                nginx.conf.tmpl
                site.conf.tmpl
                test.site.json
                test.location.json
            ]
            let config = ls config/**/*
                | where type == file
                | each { $in.name |path relative-to config }
                | each { [-v $"($_.wd)/config/($in):/etc/openresty/($in)"] }
            mut args = [
                --rm -it --name=test
                -p 8020:80
                -v $"($_.wd)/entrypoint/openresty.sh:/entrypoint/openresty.sh"
                $config
                -e ed25519_root=123
                -e FASTCGI=php
                -e IGNORE_INDEX=1
                -e FASTCGI_PATHINFO=1
                -e NCHAN=1
                -e ABOUT=""
                -e REAL_REMOTE=""
            ]
            if 'upload' in $a { $args ++= [[-e UPLOAD_ROOT=upload/]] }
            if 'pass' in $a { $args ++= [[-e HTPASSWD=admin:123]] }
            if 'route' in $a { $args ++= [[-e ROUTEFILE=/etc/openresty/test.location.json]] }
            if 'site' in $a { $args ++= [[-e SITEFILE=/etc/openresty/test.site.json]] }
            pp $env.docker-cli run ...$args localhost/0x:openresty bash
        }
        $_.cmp: { [
            upload
            pass
            route
            site
        ] }
    }
}}
