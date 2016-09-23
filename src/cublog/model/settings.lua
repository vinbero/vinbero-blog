local _M = {}

_M.Settings = {}
_M.Settings.__index = _M.Settings

function _M.Settings.new()
    local self = setmetatable({}, _M.Settings)
    self["DATABASE"] = "cublog.db"
    self["ADMIN-ID"] = "admin"
    self["ADMIN-PASSWORD"] = "password"
    self["JWT-KEY"] = "jwt-key"
    self["JWT-ISSUER"] = "cublog"
   return self
end

return _M
