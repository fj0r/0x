local json = require('cjson')
local res, err = ngx.location.capture("/v2/_catalog")
local repos = json.decode(res.body).repositories
local tags = {}
for _, r in pairs(repos) do
    local res, err = ngx.location.capture("/v2/"..r.."/tags/list")
    local ts = json.decode(res.body).tags
    --ngx.say(json.encode(ts))
    tags[r] = {}
    for _, t in pairs(ts) do
        local m, err = ngx.location.capture("/v2/"..r.."/manifests/"..t)
        local d = json.decode(json.decode(m.body).history[1].v1Compatibility).created
        table.insert(tags[r], {tag = t, created = d})
    end
    table.sort(tags[r], function (a, b)
        return a.created > b.created
    end)
end
ngx.say(json.encode(tags))
ngx.exit(200)
