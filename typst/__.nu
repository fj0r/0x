export def loc [] {
    let d = date now
    let dz = $d | format date '%Y年%m月%d日'
    let f = [y m d]
    | each {|x| $d | format date $"%($x)"}
    | path join
    | $"($in).typ"

    if ($f | path exists | not $in) {
        if ($f | path dirname | path exists | not $in) {
            mkdir ($f | path dirname)
            mkdir ([out $f] | path join | path dirname)
        }

        mut t = open templates/journal.tmpl.typ
        for i in ({} | upsert date $dz | transpose k v) {
            $t = ($t | str replace -a $"{{($i.k)}}" $i.v)
        }
        $t | save -f $f
    }
    e $f
}

def cmpl-gen [] {
    let d = [y m] | each {|x| date now | format date $"%($x)"}
    let g = [...$d '*.typ'] | path join
    ls ($g | into glob) | sort-by modified -r | get name
}

export def gen [file:string@cmpl-gen] {
    let out = $file
    | path parse
    | update extension pdf
    | update parent {|x| [ out $x.parent] | path join }
    | path join
    pp $env.CNTRCTL run ...[
        --name typst
        --rm
        --workdir '/world'
        -v $"($env.PWD):/world"
    ] '0x:typst' ...[
        typst compile $file $out --root '/world'
    ]
    evince $out
}

export def clean [] {
    rm *.pdf
}

export def sync [] {
    rsync -avp $"($env.PWD)/templates/" $"($env.HOME)/data/docker.io/0x/typst/templates/"
    for i in [',.nu' '.gitignore'] {
        rsync -avp $"($env.PWD)/($i)" $"($env.HOME)/data/docker.io/0x/typst/($i)"
    }
}
