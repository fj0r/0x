local json = require('cjson')
local res, err = ngx.location.capture("/v2/_catalog")
local repos = json.decode(res.body).repositories
local tags = {}
local zerotime = '0000-00-00T00:00:00.000000000Z'
for _, r in pairs(repos) do
    local res = ngx.location.capture("/v2/"..r.."/tags/list")
    local ts = json.decode(res.body).tags
    tags[r] = {}
    ngx.req.set_header('Accept', 'application/vnd.oci.image.manifest.v1+json')
    for _, t in pairs(ts ~= json.null and ts or {}) do
        local m, err = ngx.location.capture("/v2/"..r.."/manifests/"..t)
        local body = json.decode(m.body)
        if body.history then
            local d = json.decode(body.history[1].v1Compatibility).created
            table.insert(tags[r], {tag = t, created = d})
        else
            table.insert(tags[r], {tag = t, created = zerotime})
        end
    end
    table.sort(tags[r], function (a, b)
        if not (a.created == zerotime or b.created == zerotime) then
            return a.created > b.created
        else
            return a.tag > b.tag
        end
    end)
end
ngx.say(json.encode(tags))
ngx.exit(200)
