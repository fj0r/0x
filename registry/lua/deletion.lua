local json = require('cjson')
local h = require('resty.http').new()
local res, err = h:request_uri("http://127.0.0.1:5000/admin/list", {method = 'GET'})
local d = json.decode(res.body)
for repo, items in pairs(d) do
    for _, item in ipairs{ table.unpack(items, 2, #items) } do
        ngx.say(item.created..'\t'..repo..':'..item.tag)
    end
end
