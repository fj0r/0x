### {{{ base.nu
$env.comma_scope = {|_|{ created: '2024-06-04{2}15:22:07' }}
$env.comma = {|_|{}}
### }}}

### {{{ 01_env.nu
for e in [nuon toml yaml json] {
    if ($".env.($e)" |  path exists) {
        open $".env.($e)" | load-env
    }
}
### }}}

### {{{ 07_dev_container.nu
'dev'
| comma val null {
    container: ['0x:php7']
    id: 'test-php'
    wd: '/world'
    pubkey: 'id_ed25519.pub'
    user: root
    privileged: false
    proxy: $"http://(ip route | lines | get 0 | parse -r 'default via (?<gateway>[0-9\.]+) dev (?<dev>\w+)( proto dhcp src (?<lan>[0-9\.]+))?' | get 0.lan):7890"
}

'dev env'
| comma val null {
    PREFER_ALT: 1
    NEOVIM_LINE_SPACE: 2
    NEOVIDE_SCALE_FACTOR: 0.7
}


'dev container up'
| comma fun {|a,s,_|
    , dev container down
    let port = $a.0
    lg level 3 {
        container: $s.dev.id, workdir: $s.dev.wd
        port: $port, pubkey: $s.dev.pubkey
    } start

    pp $env.docker-cli network create $s.dev.id

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
        -v $"($_.wd):($s.dev.wd)"
        -w $s.dev.wd
        -p $"($port):8090"
        -e $"ed25519_($s.dev.user)=($sshkey)"
    ]
    $args ++= $dev

    $args ++= [
        -e PHP_PROFILE='1'
        -e PHP_DEBUG='1'
        -v $"($env.PWD)/../openresty/entrypoint/openresty.sh:/entrypoint/openresty.sh"
        -v $"($env.PWD)/setup-php:/setup-php"
        -v $"($env.PWD)/webgrind.json:/webgrind.json"
        -e $"SITEFILE=/webgrind.json"
    ]

    $args ++= ($s.dev.env
    | items {|k,v| [-e $"($k)=($v)"]}
    | flatten)

    pp $env.docker-cli run --name $s.dev.id -d ...$args ...$s.dev.container
} {
    cmp: {|a,s|
        match ($a | length) {
            1 => [(port 9992)]
            _ => {}
        }
    }
}

'dev container down'
| comma fun {|a,s|
    let ns = ^$env.docker-cli network ls | from ssv -a | get NAME
    if $s.dev.id in $ns {
        lg level 2 { container: $s.dev.id } 'stop'
        pp $env.docker-cli rm -f $s.dev.id
        pp $env.docker-cli network rm $s.dev.id
    } else {
        lg level 3 { container: $s.dev.id } 'not running'
    }
}
### }}}

