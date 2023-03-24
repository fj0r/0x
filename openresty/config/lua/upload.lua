local function file_exists(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

function dirname (path)
    local f = io.popen('dirname '..path)
    if f == nil then return end
    local r = f:read()
    f:close()
    return r
end

local env_root = os.getenv('UPLOAD_ROOT')
local root_path = ngx.var.document_root .. '/' .. (env_root and env_root .. '/' or '' )
local target = root_path .. ngx.var.path
local target_dir = dirname(target)

if file_exists(target_dir) ~= true then
    ngx.say('mkdir -p '..target_dir)
    local status = os.execute('mkdir -p '..target_dir)
    if status ~= true then
        return nil, '创建目录失败'
    end
end

ngx.req.read_body()
local data = ngx.req.get_body_data()

if nil == data then
    local file_name = ngx.req.get_body_file()
    os.execute('mv '..file_name..' '..target)
else
    local file = io.open(target, "w+")
    if file then
        file:write(data)
        file:close()
    else
        ngx.say('打开文件失败')
    end
end
