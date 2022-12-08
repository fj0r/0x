local cjson = require('cjson')
local h = require('resty.http').new()
local res, err = h:request_uri("http://127.0.0.1:5001/v2/_catalog", {method = 'GET'})
local repos = cjson.decode(res.body).repositories
local tags = {}
for _, r in pairs(repos) do
    local res, err = h:request_uri("http://127.0.0.1:5001/v2/"..r.."/tags/list", {method = 'GET'})
    local ts = cjson.decode(res.body).tags
    for _, t in pairs(ts) do
        local m, err = h:request_uri("http://127.0.0.1:5001/v2/"..r.."/minifests/"..t, {method = 'GET'})
        local d = true -- cjson.decode(cjson.decode(m.body).history[0].v1Compatibility).created
        tags[r..':'..t] = d
    end
end
ngx.say(cjson.encode(tags))
ngx.exit(200)
