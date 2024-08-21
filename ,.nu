### {{{ base.nu
$env.comma_scope = {|_|{ created: '2024-08-20{2}18:47:52' }}
$env.comma = {|_|{}}
### }}}

### {{{ 01_env.nu
for e in [nuon toml yaml json] {
    if ($".env.($e)" |  path exists) {
        open $".env.($e)" | load-env
    }
}
### }}}


'cp qng'
| comma fun {|a,s,_|
    for i in [or openresty] {
        cp ~/world/qngx/main.js ([$i 'config' 'qng.js'] | path join)
    }
}
