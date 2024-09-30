export def 'cp qng' [] {
    for i in [or openresty] {
        cp ~/world/qngx/main.js ([$i 'config' 'qng.js'] | path join)
        cp ~/world/qngx/config.json ([$i 'config' 'qng.example.json'] | path join)
    }
}
