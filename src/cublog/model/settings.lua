local _M = {}
local json = require "rapidjson"
_M.__index = _M

function _M.new()
    local self = setmetatable({}, _M)
    local file = io.open(vinbero.arg)
    if file == nil then
       error("Databse not found") 
    end
    local content = file:read("a")
    for key, value in pairs(json.decode(content)) do
        self[key] = value
    end
    file:close()
    return self
end

return _M
