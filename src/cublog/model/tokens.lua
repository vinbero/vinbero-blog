local _M = {}

local jwt = require "luajwt"
local settings = require "cublog.model.settings".Settings.new()

_M.Tokens = {}
_M.Tokens.__index = _M.Tokens

function _M.Tokens.new()
    local self = setmetatable({}, _M.Tokens)
    return self
end

function _M.Tokens:create()
    local payload = {
        iss = settings["JWT-ISSUER"],
        nbf = os.time(),
        exp = os.time() + 3600,
    }

    local alg = "HS256"
    local token, err = jwt.encode(payload, settings["JWT-KEY"], alg)

    return token 
end

function _M.Tokens:isValid(token)
    return jwt.decode(token, settings["JWT-KEY"], true) ~= nil
end

return _M
