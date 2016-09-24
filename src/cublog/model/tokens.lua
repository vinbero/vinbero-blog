local _M = {}
local jwt = require "gonapps.jwt"
local settings = require "cublog.model.settings".new()

_M.__index = _M

function _M.new()
    local self = setmetatable({}, _M)
    return self
end

function _M:create()
    local payload = {
        iss = settings["JWT-ISSUER"],
        nbf = os.time(),
        exp = os.time() + 3600,
    }
    local alg = "HS256"
    local token, err = jwt.encode(payload, settings["JWT-KEY"], alg)
    return token 
end

function _M:isValid(token)
    local ok = pcall(jwt.decode, token, settings["JWT-KEY"])
    return ok
end

return _M
