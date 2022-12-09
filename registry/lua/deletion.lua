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
        ngx.say('---------delete > '..t[1]..':'..t[2]..'['.. digest ..']')
        ngx.location.capture('/v2/'..t[1]..'/manifests/'..digest, {method = ngx.HTTP_DELETE})
    end

    ngx.say('---------garbage-collect---------')
    local shell = require "resty.shell"
    local stdin = "hello"
    local timeout = 1000  -- ms
    local max_size = 4096  -- byte
    local ok, stdout, stderr, reason, status =
        shell.run([[/usr/local/bin/registry garbage-collect --delete-untagged /etc/docker/registry/config.yml]], stdin, timeout, max_size)
    ngx.say(stdout)
    ngx.exit(200)
end

