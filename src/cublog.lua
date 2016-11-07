local json = require "rapidjson"
local urlDecoder = require "gonapps.url.decoder"
local Cookie = require "gonapps.cookie"
local urlQueryParser = require "gonapps.url.query.parser"

local Router = require "tucube.http.router"
local Settings = require "cublog.model.settings"
local Posts = require "cublog.model.posts"
local Tokens = require "cublog.model.tokens"

local router = Router.new()
local settings = Settings.new()
local posts = Posts.new()
local tokens = Tokens.new()

router:setCallback("^/posts/?$", "POST", function(request)
    local cookie = Cookie.new(request.headers["COOKIE"])
    if cookie.data["CublogToken"] == nil or not tokens:isValid(cookie.data["CublogToken"]) then
        return 403, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "null"
    end
    local ok, post = pcall(json.decode, request.body)
    if not ok then
        return 400, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "null"
    end
    local id = posts:create(post)
    if id == nil then
        return 500, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "null"
    end
    return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, id
end)

router:setCallback("^/posts/?$", "GET", function(request)
    return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, json.encode(posts:getAll()) 
end)

router:setCallback("^/posts/(?<id>\\d+)$", "GET", function(request)
    local post = posts:get({["id"] = request.parameters["id"]})
    if post ~= nil then
        local cookie = Cookie.new(request.headers["COOKIE"])
        if (post.private == true or post.private == 1) and (cookie.data["CublogToken"] == nil or not tokens:isValid(cookie.data["CublogToken"])) then
            return 403, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "null"
        end
        return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, json.encode(post)
    end 
    return 400, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "null"
end)

router:setCallback("^/posts/(?<id>\\d+)$", "PUT", function(request)
    local cookie = Cookie.new(request.headers["COOKIE"])
    if cookie.data["CublogToken"] == nil or not tokens:isValid(cookie.data["CublogToken"]) then
        return 403, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "null"
    end
    local ok, post = pcall(json.decode, request.body)
    if not ok then
        return 400, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "null"
    end
    if posts:update(post) then
        return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "true"
    end
    return 500, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "false"
end)

router:setCallback("^/posts/(?<id>\\d+)$", "DELETE", function(request)
    local cookie = Cookie.new(request.headers["COOKIE"])
    if cookie.data["CublogToken"] == nil or not tokens:isValid(cookie.data["CublogToken"]) then
        return 403, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "null"
    end
    if posts:delete({["id"] = request.parameters["id"]}) then
        return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "true"
    end 
    return 500, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "false"
end)

router:setCallback("^/tokens/?$", "POST", function(request)
    local ok, login = pcall(json.decode, request.body)
    if not ok then
        return 400, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "null"
    end
    if login.id == settings["ADMIN-ID"] and login.password == settings["ADMIN-PASSWORD"] then
        local cookie = Cookie.new()
        cookie.data["CublogToken"] = tokens:create()
        cookie.flags["HttpOnly"] = true
        return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*", ["Set-Cookie"] = cookie:toString()}, "true"
    end 
    return 403, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "null"
end)

function onRequestFinish(request)
    urlQueryParser.parse(request.queryString, request.parameters)
    return router:route(request)
end

function onDestroy()
    posts:destroy()
end
