local json = require('cjson')
local METHOD = ngx.req.get_method()
if METHOD == 'GET' then
    local res, err = ngx.location.capture("/admin/list", {method = ngx.HTTP_GET})
    local d = json.decode(res.body)
    local retain = ngx.req.get_uri_args().retain
    for repo, items in pairs(d) do
        for _, item in ipairs{ table.unpack(items, retain and retain + 1 or 1, #items) } do
            ngx.say(item.created..'\t'..repo..':'..item.tag)
        end
    end
    ngx.exit(200)
elseif METHOD == 'GC' then
    -- registry garbage-collect /etc/docker/registry/config.yml
    local exec = require'resty.exec'
    local prog = exec.new('/tmp/exec.sock')
    local res, err = prog('pwd')
    ngx.say(res.stdout)
    ngx.exit(200)
else
    local split = function (str, sep)
        local r = {}
        for i in str:gmatch("[^"..sep.."]+") do
            table.insert(r, i)
        end
        return r
    end
    ngx.req.read_body()
    local data = ngx.req.get_body_data()
    for _, s in ipairs(split(data, '\r\n')) do
        local t = split(split(s, '\t')[2], ':')
        ngx.req.set_header('Accept', 'application/vnd.docker.distribution.manifest.v2+json')
        local digest = ngx.location.capture('/v2/'..t[1]..'/manifests/'..t[2]).header['Docker-Content-Digest']
        ngx.location.capture('/v2/'..t[1]..'/manifests/'..digest, {method = ngx.HTTP_DELETE})
        ngx.say('delete> '..t[1]..':'..t[2]..'['.. digest ..']')
    end
    ngx.exit(200)
end

