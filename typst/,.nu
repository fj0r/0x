### {{{ base.nu
$env.comma_scope = {|_|{ created: '2024-05-16{4}09:11:24' }}
$env.comma = {|_|{}}
### }}}

### {{{ 03_reload.nu
'. reload'
| comma fun {|a,s,_|
    let act = $a | str join ' '
    $', ($act)' | batch -i ',.nu'
} {
    watch: { glob: ",.nu", clear: true }
    completion: {|a,s|
        , -c ...$a
    }
    desc: "reload & run ,.nu"
}
### }}}

'new'
| comma fun {|a,s,_|
    mut t = open templates/journal.tmpl.typ
    let d = date now
    let dz = $d | format date '%Y年%m月%d日'
    let d = $d | format date '%y%m%d'
    for i in ({} | upsert date $dz | transpose k v) {
        $t = ($t | str replace -a $"{{($i.k)}}" $i.v)
    }
    let f = $"($d).typ"
    if ($f | path exists) {
        let a = [no yes] | input list '文件已存在，是否覆盖？'
        if $a == 'no' { return }
    }
    $t | save -f $f
}

'gen'
| comma fun {|a,s,_|
    pp $env.CONTCTL run ...[
        --name typst
        --rm
        --workdir '/world'
        -v $"($env.PWD):/world"
    ] '0x:typst' ...[
        typst compile $a.0 $"out/($a.0).pdf"
    ]
    zathura $"out/($a.0).pdf"
} {
    cmp: {
        ls *.typ | sort-by modified -r | get name
    }
    wth: { glob: '*.typ' }
}

'clean'
| comma fun {|a,s,_|
    rm *.pdf
}

'sync'
| comma fun {|a,s,_|
    rsync -avp $"($env.PWD)/templates/" $"($env.HOME)/data/docker.io/0x/typst/templates/"
    for i in [',.nu' '.gitignore'] {
        rsync -avp $"($env.PWD)/($i)" $"($env.HOME)/data/docker.io/0x/typst/($i)"
    }
}
