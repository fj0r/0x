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
    function split (str, sep)
        local r = {}
        for i in str:gmatch("[^"..sep.."]+") do
            table.insert(r, i)
        end
        return r
    end

    function getFile(file_name)
        local f = assert(io.open(file_name, 'r'))
        local string = f:read("*all")
        f:close()
        return string
    end

    ngx.req.read_body()
    local data = ngx.req.get_body_data()
    if nil == data then
        local file_name = ngx.req.get_body_file()
        if file_name then
            data = getFile(file_name)
        end
    end

    ngx.say(os.date('%Y-%m-%d|%H:%M:%S')..'---------delete---------')
    for _, s in ipairs(split(data, '\r\n')) do
        local t = split(split(s, '\t')[2], ':')
        local DockerHeader = 'application/vnd.docker.distribution.manifest.v2+json'
        local OciHeader = 'application/vnd.oci.image.manifest.v1+json'
        ngx.req.set_header('Accept', OciHeader)
        local res = ngx.location.capture('/v2/'..t[1]..'/manifests/'..t[2])
        local digest = res.header['Docker-Content-Digest']
        ngx.say('delete: '..t[1]..':'..t[2]..'['.. digest ..']')
        ngx.location.capture('/v2/'..t[1]..'/manifests/'..digest, {method = ngx.HTTP_DELETE})
    end

    ngx.say(os.date('%Y-%m-%d|%H:%M:%S')..'---------garbage-collect---------')
    local shell = require "resty.shell"
    local stdin = "hello"
    local timeout = 600000  -- ms
    local max_size = 1024000  -- byte
    local ok, stdout, stderr, reason, status =
        shell.run([[/usr/local/bin/registry garbage-collect --delete-untagged /etc/docker/registry/config.yml]], stdin, timeout, max_size)
    ngx.say(stdout)
    ngx.say('---------')
    ngx.say(stderr)
    ngx.say(os.date('%Y-%m-%d|%H:%M:%S')..'---------finish---------')
    ngx.exit(200)
end

