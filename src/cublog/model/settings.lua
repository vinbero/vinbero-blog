local _M = {}
_M.__index = _M

function _M.new()
    local self = setmetatable({}, _M)
    self["DATABASE"] = "cublog.db"
    self["ADMIN-ID"] = "admin"
    self["ADMIN-PASSWORD"] = "password"
    self["JWT-KEY"] = "jwt-key"
    self["JWT-ISSUER"] = "cublog"
   return self
end

return _M
