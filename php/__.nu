const s = {
    dev: {
        container: ['0x:php7']
        id: 'test-php'
        wd: '/world'
        pubkey: 'id_ed25519.pub'
        user: root
        privileged: false
        #proxy: $"http://(ip route | lines | get 0 | parse -r 'default via (?<gateway>[0-9\.]+) dev (?<dev>\w+)( proto dhcp src (?<lan>[0-9\.]+))?' | get 0.lan):7890"
        env: {
            PREFER_ALT: 1
            NEOVIM_LINE_SPACE: 2
            NEOVIDE_SCALE_FACTOR: 0.7
        }
    }
}

def cmpl-port [] {
    port 9992
}

export def 'dev container up' [port:int@cmpl-port] {
    , dev container down
    lg level 3 {
        container: $s.dev.id, workdir: $s.dev.wd
        port: $port, pubkey: $s.dev.pubkey
    } start

    pp $env.CONTCTL network create $s.dev.id

    mut args = []

    $args ++= [--network $s.dev.id]

    $args ++= if $s.dev.privileged {[
        --privileged
    ]} else {[
        --cap-add=SYS_ADMIN
        --cap-add=SYS_PTRACE
        --security-opt seccomp=unconfined
        --cap-add=NET_ADMIN
        --device /dev/net/tun
    ]}

    if ($s.dev.proxy? | is-not-empty) {
        #$args ++= [ -e $"http_proxy=($s.dev.proxy)" -e $"https_proxy=($s.dev.proxy)" ]
    }

    if ($env.DISPLAY? | is-not-empty) {
        $args ++= [ -e $"DISPLAY=($env.DISPLAY)" -v /tmp/.X11-unix:/tmp/.X11-unix ]
    }

    let sshkey = cat ([$env.HOME .ssh $s.dev.pubkey] | path join) | split row ' ' | get 1
    let dev = [
        -v $"($env.PWD):($s.dev.wd)"
        -w $s.dev.wd
        -p $"($port):80"
        -e $"ed25519_($s.dev.user)=($sshkey)"
    ]
    $args ++= $dev

    $args ++= [
        -e LOG_FORMAT=json
        -v $"($env.PWD)/../openresty/config/nginx.conf.tmpl:/etc/openresty/nginx.conf.tmpl"
        -v $"($env.PWD)/../openresty/config/site.conf.tmpl:/etc/openresty/site.conf.tmpl"
        -v $"($env.PWD)/../openresty/config/default.json:/etc/openresty/default.json"
        #-e PHP_PROFILE='1'
        #-e PHP_DEBUG=host.containers.internal:9001
        -e PHP_DEBUG=localhost:9000
        -v $"($env.PWD)/../openresty/entrypoint/openresty.sh:/entrypoint/openresty.sh"
        -v $"($env.PWD)/setup-php:/setup-php"
        -v $"($env.PWD)/webgrind.json:/etc/openresty/webgrind.json"
        #-e $"SITEFILE=/etc/openresty/webgrind.json"
    ]

    $args ++= ($s.dev.env
    | items {|k,v| [-e $"($k)=($v)"]}
    | flatten)

    pp $env.CONTCTL run --name $s.dev.id -d ...$args ...$s.dev.container
}

export def 'dev container down' [] {
    let ns = ^$env.CONTCTL network ls | from ssv -a | get NAME
    if $s.dev.id in $ns {
        lg level 2 { container: $s.dev.id } 'stop'
        pp $env.CONTCTL rm -f $s.dev.id
        pp $env.CONTCTL network rm $s.dev.id
    } else {
        lg level 3 { container: $s.dev.id } 'not running'
    }
}

