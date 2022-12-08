local json = require('cjson')
local res, err = ngx.location.capture("/admin/list", {method = ngx.HTTP_GET})
local d = json.decode(res.body)
for repo, items in pairs(d) do
    for _, item in ipairs{ table.unpack(items, 2, #items) } do
        ngx.say(item.created..'\t'..repo..':'..item.tag)
    end
end
