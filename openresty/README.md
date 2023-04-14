### short-url
```
    lua_shared_dict short_url 1m;

    init_by_lua_block {
        local cjson = require('cjson')
        local f = io.open('/srv/short-url.json', 'r')
        local data = f:read("*a")
        f:close()
        local url = ngx.shared.short_url
        for k, v in pairs(cjson.decode(data)) do
           url:set(k, v)
        end
    }

    server {
        location ~ ^/-(.+) {
             content_by_lua_block {
                 ngx.redirect(ngx.shared.short_url:get(ngx.var[1]))
             }
        }
    }
```
