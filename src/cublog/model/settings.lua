local _M = {}
local json = require "rapidjson"
_M.__index = _M

function _M.new()
    local self = setmetatable({}, _M)
    for key, value in pairs(json.decode(vinbero.args)) do
        self[key] = value
    end
    return self
end

return _M
