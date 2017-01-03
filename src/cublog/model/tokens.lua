local _M = {}
local jwt = require "gonapps.jwt"
local Settings = require "cublog.model.settings"
local settings = Settings.new()

_M.__index = _M

function _M.new()
    local self = setmetatable({}, _M)
    return self
end

function _M:create()
    local payload = {
        iss = settings["jwt.issuer"],
        nbf = os.time(),
        exp = os.time() + 3600,
    }
    local alg = "HS256"
    local token, err = jwt.encode(payload, settings["jwt.key"], alg)
    return token 
end

function _M:isValid(token)
    local ok = pcall(jwt.decode, token, settings["jwt.key"])
    return ok
end

return _M
