$env.comma_scope = {|_|{
    created: '2024-03-27{3}11:05:20'
    computed: {$_.computed:{|a, s| $'($s.created)($a)' }}
    log_args: {$_.filter:{|a, s| do $_.tips 'received arguments' $a }}
    cmd: {$_.filter:{|a,s|
            let dir = open $a.0 | get name
            let img = image-select 'fj0rd/0x:nebula'
            let cmd = [
                $env.CNTRCTL run
                --name nebula-util --rm
                -v $"($_.wd)/data/($dir):/world"
                --workdir=/world
                --entrypoint=nebula-cert
                $img
            ]
            { cmd: $cmd }
    }}
    config: {$_.filter:{|a,s|
        let cfg = open $a.0
        let network = $cfg.name
        let cidr = $cfg.cidr | split row '/'
        mut caddr = $cidr.0 | split row '.' | each {|x| $x | into int }
        let cmask = $cidr.1 | into int
        if $cmask != 16 {
            lg crt 'mask must be 16' {mask: $cmask, type: ($cmask | describe)}
            return
        }
        mut sn2 = 0
        mut sn3 = 1
        mut lighthouse = []
        for l in ($cfg.lighthouse | transpose k v) {
            $caddr.2 = $sn2
            $caddr.3 = $sn3
            $lighthouse ++= {
                name: $l.k
                vaddr: ($caddr | str join '.')
                ...$l.v
            }
            $sn3 += 1
        }
        mut sn3 = 100
        mut node = []
        for n in ($cfg.node | transpose k v) {
            $caddr.2 = $sn2
            $caddr.3 = $sn3
            $node ++= {
                name: $n.k
                vaddr: ($caddr | str join '.')
                ...$n.v
            }
            if $sn3 >= 254 {
                $sn2 += 1
                $sn3 = 1
            } else {
                $sn3 += 1
            }
        }
        let config = {
            network: $network
            cidr: $cidr
            lighthouse: $lighthouse
            node: $node
        }
        { config: $config }
    }}
    config_file: {|cfg|
        let port = if $cfg.lighthouse { $cfg.host | split row ':' | get 1 | into int } else { 0 }
        let hosts = if $cfg.lighthouse { [] } else { $cfg.vhosts }
        {
            listen: { port: $port }
            lighthouse: {
                am_lighthouse: $cfg.lighthouse
                interval: 60
                hosts: $hosts
                serve_dns: $cfg.lighthouse
            }
            static_host_map: $cfg.static_map
            pki: { ca: $cfg.ca, cert: $cfg.cert, key: $cfg.key }
            ciphers: 'aes' # 'chachapoly'
            punchy: {
                punch: true
                respond: true
                delay: 1s
            }
            relay: {
                am_relay: $cfg.relay
                use_relays: (not $cfg.relay)
                relays: (if $cfg.relay { [] } else { $cfg.relays })
            }
            tun: {
                dev: (if $cfg.lighthouse { null } else { 'nebula1' })
                disabled: $cfg.lighthouse
            }
            firewall: {
                inbound: [
                    {
                        port: any
                        proto: any
                        ...(if $cfg.lighthouse {
                                {host: any}
                            } else {
                                {groups: $cfg.group}
                            })
                    }
                ]
            }
            sshd: {
                enabled: $cfg.lighthouse
                listen: $'0.0.0.0:2222'
                host_key: '/nebula/ssh_host_ed25519_key'
                authorized_users: [
                    {user: root, keys: $cfg.sshkey}
                ]
            }
        }
    }
}}

$env.comma = {|_|{
    new: {
        $_.a: {|a,s|
            let config = $s.config
            let basedir = [$_.wd 'data' $config.network]

            if false {
                let p = [...$basedir '*'] | path join | into glob
                rm -rf $p
            }

            let network_exist = [...$basedir 'ca.key'] | path join | path exists
            let ll = if $network_exist { 'wrn' } else { 'msg' }
            lg $ll {act: create type: network net: $config.network ignore: $network_exist}
            if not $network_exist {
                pp ...$s.cmd ...[ca -name $config.network -duration 876000h0m0s]
            } else {
            }

            let cfg = open $"($_.wd)/config.yaml"
            let ca = open ([...$basedir 'ca.crt'] | path join)
            let vhosts = $config.lighthouse | get vaddr
            let static_map = $config.lighthouse | reduce -f {} {|i,a| $a | insert $i.vaddr $i.host }
            let relay = $config.lighthouse | get vaddr
            for h in [lighthouse node] {
                for i in ($config | get $h) {
                    let name = if $h == 'lighthouse' { $"_($i.name)" }  else { $i.name }
                    let dir = [...$basedir $name] | path join
                    let node_exist = $dir | path exists
                    let ll = if $node_exist { 'wrn' } else { 'msg' }
                    let cidr = $"($i.vaddr)/($config.cidr.1)"
                    lg $ll {act: create type: $h net: $config.network ignore: $node_exist name: $name cidr: $cidr}
                    if not $node_exist {
                        cd ($basedir | path join)
                        pp ...$s.cmd ...[sign -name $"($name)" -ip $cidr -groups $i.group]
                        mkdir $dir
                        ssh-keygen -t ed25519 -f "ssh" -C $name -q -N ''
                        for f in [$"($name).crt" $"($name).key" "ssh" "ssh.pub"] {
                            mv $f $dir
                        }
                    }
                    let cert = open ([$dir $"($name).crt"] | path join)
                    let key = open ([$dir $"($name).key"] | path join)
                    let pubkey = open ([$dir $"ssh.pub"] | path join)
                    let c = {
                        lighthouse: ($h == 'lighthouse')
                        vaddr: $i.vaddr
                        host: $i.host?
                        group: $i.group
                        vhosts: $vhosts
                        relay: ($h == 'lighthouse')
                        relays: $relay
                        static_map: $static_map
                        ca: $ca
                        cert: $cert
                        key: $key
                        sshkey: $pubkey
                    }
                    let output = [$dir "config.yaml"] | path join
                    $"# ($i.name): ($cidr)(char newline)" | save -f $output
                    $cfg | merge (do $s.config_file $c) | save -af $output
                }
            }
        }
        $_.flt: [cmd config]
        $_.cmp: {|a,s| ls *.network.yaml | get name }
    }
    sync: {
        cp $"($_.wd)/,.nu" ~/data/docker.io/0x/nebula/,.nu
    }
    .: {
        .: {
            $_.action: {|a,s|
                let act = $a | str join ' '
                $', ($act)' | batch -i ',.nu'
            }
            $_.watch: { glob: ",.nu", clear: true }
            $_.completion: {|a,s|
                , -c ...$a
            }
            $_.desc: "reload & run ,.nu"
        }
        nu: {
            $_.action: {|a,s| nu $a.0 }
            $_.watch: { glob: '*.nu', clear: true }
            $_.completion: { ls *.nu | get name }
            $_.desc: "develop a nu script"
        }
        py: {
            $_.action: {|a,s| python3 $a.0 }
            $_.watch: { glob: '*.py', clear: true }
            $_.completion: { ls *.py| get name }
            $_.desc: "develop a python script"
        }
        created: {
            $_.action: {|a, s| $s.computed }
            $_.filter: [log_args]
            $_.desc: "created"
        }
        inspect: {|a, s| {index: $_, scope: $s, args: $a} | table -e }
        vscode-tasks: {
            $_.action: {
                mkdir .vscode
                ', --vscode -j' | batch ',.nu' | save -f .vscode/tasks.json
            }
            $_.desc: "generate .vscode/tasks.json"
            $_.watch: { glob: ',.nu' }
        }
    }
}}
