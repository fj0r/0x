def _proxy [] {
    $"http://(ip route | lines | get 0 | parse -r 'default via (?<gateway>[0-9\.]+) dev (?<dev>\w+)( proto dhcp src (?<lan>[0-9\.]+))?' | get 0.lan):7890"
}

def cmpl-port [] {
    port 9992
}

export def 'dev container up' [port:int@cmpl-port] {
    dev container down
    lg level 3 {
        container: $env.dev.id, workdir: $env.dev.wd
        port: $port, pubkey: $env.dev.pubkey
    } start

    pp $env.CNTRCTL network create $env.dev.id

    mut args = []

    $args ++= [--network $env.dev.id]

    $args ++= if $env.dev.privileged {[
        --privileged
    ]} else {[
        --cap-add=SYS_ADMIN
        --cap-add=SYS_PTRACE
        --security-opt seccomp=unconfined
        --cap-add=NET_ADMIN
        --device /dev/net/tun
    ]}

    if ($env.dev.proxy? | is-not-empty) {
        #$args ++= [ -e $"http_proxy=($env.dev.proxy)" -e $"https_proxy=($env.dev.proxy)" ]
    }

    if ($env.DISPLAY? | is-not-empty) {
        $args ++= [ -e $"DISPLAY=($env.DISPLAY)" -v /tmp/.X11-unix:/tmp/.X11-unix ]
    }

    let sshkey = cat ([$env.HOME .ssh $env.dev.pubkey] | path join) | split row ' ' | get 1
    let dev = [
        -v $"($env.PWD):($env.dev.wd)"
        -w $env.dev.wd
        -p $"($port):80"
        -e $"ed25519_($env.dev.user)=($sshkey)"
    ]
    $args ++= $dev

    $args ++= [
        -e QNGCONFIG=/etc/openresty/qng.example.json
        -e QNG_ABOUT_ENABLE="0"
        -e QNG_HELLO_ENABLE="1"
        -e QNG_WORKER_PROCESSES="8"
        -e LOG_FORMAT=json
        -v $"($env.PWD)/../openresty/config/qng.js:/etc/openresty/qng.js"
        #-e PHP_PROFILE='1'
        #-e PHP_DEBUG=host.containers.internal:9001
        -e PHP_DEBUG=localhost:9000
        -v $"($env.PWD)/../openresty/entrypoint/openresty.sh:/entrypoint/openresty.sh"
        -v $"($env.PWD)/setup-php:/setup-php"
        -v $"($env.PWD)/webgrind.json:/etc/openresty/webgrind.json"
        #-e $"SITEFILE=/etc/openresty/webgrind.json"
    ]

    $args ++= ($env.dev.env
    | items {|k,v| [-e $"($k)=($v)"]}
    | flatten)

    pp $env.CNTRCTL run --name $env.dev.id -d ...$args ...$env.dev.container
}

export def 'dev container down' [] {
    let ns = ^$env.CNTRCTL network ls | from ssv -a | get NAME
    if $env.dev.id in $ns {
        lg level 2 { container: $env.dev.id } 'stop'
        pp $env.CNTRCTL rm -f $env.dev.id
        pp $env.CNTRCTL network rm $env.dev.id
    } else {
        lg level 3 { container: $env.dev.id } 'not running'
    }
}

