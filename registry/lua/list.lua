local json = require('cjson')
local h = require('resty.http').new()
local res, err = h:request_uri("http://127.0.0.1:5001/v2/_catalog", {method = 'GET'})
local repos = json.decode(res.body).repositories
local tags = {}
for _, r in pairs(repos) do
    local res, err = h:request_uri("http://127.0.0.1:5001/v2/"..r.."/tags/list", {method = 'GET'})
    local ts = json.decode(res.body).tags
    tags[r] = {}
    for _, t in pairs(ts) do
        local m, err = h:request_uri("http://127.0.0.1:5001/v2/"..r.."/manifests/"..t, {method = 'GET'})
        local d = json.decode(json.decode(m.body).history[1].v1Compatibility).created
        table.insert(tags[r], {tag = t, created = d})
    end
    table.sort(tags[r], function (a, b)
        return a.created > b.created
    end)
end
ngx.say(json.encode(tags))
ngx.exit(200)
