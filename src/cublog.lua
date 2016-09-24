local router = require "tucube.http.router".new()
local settings = require "cublog.model.settings".new()
local posts = require "cublog.model.posts".new()
local tokens = require "cublog.model.tokens".new()
local json = require "rapidjson"

function parseQueryString(request) -- request:parseQueryString
    if request.queryString ~= nil then
        for pair in string.gmatch(request.queryString, "([^&]+)") do
            for key, value in string.gmatch(pair, "([^=]+)=([^=]+)") do
                request.parameters[decodeURL(key)] = decodeURL(value)
            end
        end
    end
end

router:setCallback("^/posts/?$", "POST", function(request)
    local ok, token = pcall(string.match, request.headers["AUTHORIZATION"], "Bearer (.+)")
    if not ok or token == nil or not tokens:isValid(token) then
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
        local ok, token = pcall(string.match, request.headers["AUTHORIZATION"], "Bearer (.+)")
        if (post.private == true or post.private == 1) and (not ok or token == nil or not tokens:isValid(token)) then
            return 403, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "null"
        end
        return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, json.encode(post)
    end 
    return 400, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "null"
end)

router:setCallback("^/posts/(?<id>\\d+)$", "PUT", function(request)
    local ok, token = pcall(string.match, request.headers["AUTHORIZATION"], "Bearer (.+)")
    if not ok or token == nil or not tokens:isValid(token) then
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
    local ok, token = pcall(string.match, request.headers["AUTHORIZATION"], "Bearer (.+)")
    if not ok or token == nil or not tokens:isValid(token) then
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
        return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, json.encode(tokens:create())
    end 
    return 403, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "null"
end)

function getContentLength(request)
    return request.contentLength
end

function onBodyChunk(request, bodyChunk)
    request.body = request.body .. bodyChunk
end

function onRequestFinish(request)
    parseQueryString(request)
    return router:route(request)
end

function onDestroy()
    posts:destroy()
end
