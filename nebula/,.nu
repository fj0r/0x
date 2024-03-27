$env.comma_scope = {|_|{
    created: '2024-03-27{3}11:05:20'
    computed: {$_.computed:{|a, s| $'($s.created)($a)' }}
    log_args: {$_.filter:{|a, s| do $_.tips 'received arguments' $a }}
    cmd: {$_.filter:{|a,s|
            let dir = $a.0 | split row '/' | first
            let img = image-select 'fj0rd/0x:nebula'
            let cmd = [
                $env.docker-cli run
                --name nebula-util --rm
                -v $"($_.wd)/data/($dir):/world"
                --workdir=/world
                --entrypoint=nebula-cert
                $img
            ]
            { cmd: $cmd }
    }}
    cmp: {|a,s|
        match ($a | length) {
            1 => [{value: 'example', description: 'name'}]
            2 => [{value: '10.10.0.1/16', description: 'vhost'}]
            3 => [{value: '192.168.0.1:51821', description: 'host'}]
            4 => [{value: 'default', description: 'group'}]
            _ => {}
        }
    }
    arg: {|a|
        let name = $a.0 | split row '/'
        let network = $name.0
        let name = $name.1
        let vaddr = $a.1 | split row '/'
        let vcidr = $vaddr.1
        let vaddr = $vaddr.0
        let raddr = $vaddr | split row '.'
        let lighthouse_range = $a | range 4.. | append 1 | uniq | sort
        let lighthouse = ($raddr | last | into int) in $lighthouse_range
        let raddr = $lighthouse_range
        | each {|x| $raddr | range ..-2 | append $x | str join '.' } 
        let addr = $a.2 | split row ':'
        let port = $addr.1
        let addr = $addr.0
        {
            name: $name
            network: $network
            lighthouse: $lighthouse
            raddr: $raddr
            vhost : $a.1
            vaddr: $vaddr
            vcidr: $vcidr
            host: $a.2
            addr: $addr
            port: $port
            group : $a.3
        }
    }
}}

$env.comma = {|_|{
    start: {
        $_.act: {|a,s|
            ll 1 start
        }
        $_.cmp: {|a,s|
            match ($a | length) {
                1 => []
                _ => {}
            }
        }
    }
    stop: {
        l1 'stop'
    }
    new: {
        $_.a: {|a,s|
            let a = do $s.arg $a
            if $a.lighthouse {
                pp ...$s.cmd ...[ca -name $a.name -duration 876000h0m0s]
            }
            pp ...$s.cmd ...[sign -name $a.name -ip $a.vhost -groups $a.group]
            let cfg = open $"($_.wd)/config.yaml"
            let ca = open $"($_.wd)/data/($a.network)/ca.crt"
            let cert = open $"($_.wd)/data/($a.network)/($a.name).crt"
            let key = open $"($_.wd)/data/($a.network)/($a.name).key"
            let uc = {
                listen: { port: (if $a.lighthouse { $a.port } else { '0' }) }
                lighthouse: {
                    am_lighthouse: $a.lighthouse
                    hosts: [ $a.vaddr ]
                    serve_dns: $a.lighthouse
                }
                static_host_map: {
                    $a.vaddr: $a.host
                }
                pki: { ca: $ca, cert: $cert, key: $key }
                ciphers: "chachapoly"
                relay: {
                    am_relay: $a.lighthouse
                    use_relays: (not $a.lighthouse)
                    relays: (if $a.lighthouse { [] } else { $a.raddr })
                }
                tun: {
                    dev: (if $a.lighthouse { null } else { 'nebula1' })
                    disabled: (not $a.lighthouse)
                }
                firewall: {
                    inbound: [
                        {
                            port: any
                            proto: any
                            ...(if $a.lighthouse {
                                    {host: any}
                                } else {
                                    {groups: $a.group}
                                })
                        }
                    ]
                }
                sshd: {
                    enabled: $a.lighthouse
                    listen: $'($a.vaddr):2222'
                    host_key: '/nebula/ssh_host_ed25519_key'
                    authorized_users: [
                        {user: root, keys: $"ssh-ed25519 xxxxx"}
                    ]
                }
            }
            print ($cfg | merge $uc | table -e)
        }
        $_.flt: [cmd]
        $_.cmp: {|a,s| do $s.cmp $a $s }
    }
    .: {
        .: {
            $_.action: {|a,s|
                let act = $a | str join ' '
                $', ($act)' | batch ',.nu'
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
