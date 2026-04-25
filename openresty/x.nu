def cmpl [] {
    [
        qng
        upload
        pass
        route
        site
    ]
}

export def 'srv' [...a:string@cmpl] {
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
        | each { [-v $"($env.PWD)/config/($in):/etc/openresty/($in)"] }
    mut args = [
        --rm -it --name=test
        -p 8020:80
        -v $"($env.PWD)/entrypoint/openresty.sh:/entrypoint/openresty.sh"
        $config
        -e ed25519_root=123
        -e QNGCONFIG=/etc/openresty/qng.example.json
        -e QNG_FASTCGI_TYPE=php
        -e QNG_FASTCGI_IGNORE_INDEX=1
        -e QNG_FASTCGI_PATHINFO=1
        -e QNG_NCHAN=1
        -e QNG_ABOUT=""
        -e QNG_REAL_REMOTE=""
    ]
    if 'upload' in $a { $args ++= [[-e UPLOAD_ROOT=upload/]] }
    if 'pass' in $a { $args ++= [[-e HTPASSWD=admin:123]] }
    if 'route' in $a { $args ++= [[-e ROUTEFILE=/etc/openresty/test.location.json]] }
    if 'site' in $a { $args ++= [[-e SITEFILE=/etc/openresty/test.site.json]] }
    if 'qng' in $a { $args ++= [[-e QNGCONFIG=/etc/openresty/qng.example.json]] }
    pp $env.CNTRCTL run ...$args '0x:openresty' bash
}
