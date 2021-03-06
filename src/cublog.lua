local json = require "rapidjson"
local urlDecoder = require "gonapps.url.decoder"
local urlQueryParser = require "gonapps.url.query.parser"

local Router = require "gonapps.url.router"
local Settings = require "cublog.model.settings"
local Posts = require "cublog.model.posts"
local Tokens = require "cublog.model.tokens"

local router = Router.new()
local settings = Settings.new()
local posts = Posts.new()
local tokens = Tokens.new()

router:setCallback("^/posts/?$", "POST", function(request)
    local ok, token = pcall(string.match, request.headers["AUTHORIZATION"], "Bearer (.+)")
    if not ok or token == nil or not tokens:isValid(token) then
        return 403, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
    end
    local ok, post = pcall(json.decode, request.body)
    if not ok then
        return 400, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
    end
    local id = posts:create(post)
    if id == nil then
        return 500, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
    end
    return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, json.encode(posts:get({["id"] = id}))
end)

router:setCallback("^/posts/?$", "GET", function(request)
    local ok, token = pcall(string.match, request.headers["AUTHORIZATION"], "Bearer (.+)")
    local posts = posts:getAll(not (not ok or token == nil or not tokens:isValid(token)))
    local responseBody
    if #posts == 0 then
        responseBody = "[]"
    else
        responseBody = json.encode(posts)
    end
    return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, responseBody 
end)

router:setCallback("^/posts/(?<id>\\d+)$", "GET", function(request)
    local post = posts:get({["id"] = request.parameters["id"]})
    if post ~= nil then
        local ok, token = pcall(string.match, request.headers["AUTHORIZATION"], "Bearer (.+)")
        if (post.private == true or post.private == 1) and (not ok or token == nil or not tokens:isValid(token)) then
            return 403, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
        end
        return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, json.encode(post)
    end 
    return 404, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
end)

router:setCallback("^/posts/(?<id>\\d+)$", "PUT", function(request)
    local ok, token = pcall(string.match, request.headers["AUTHORIZATION"], "Bearer (.+)")
    if not ok or token == nil or not tokens:isValid(token) then
        return 403, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
    end
    local ok, post = pcall(json.decode, request.body)
    if not ok then
        return 400, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
    end
    if posts:update(post) then
        return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, json.encode(posts:get({["id"] = request.parameters["id"]}))
    end
    return 500, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
end)

router:setCallback("^/posts/(?<id>\\d+)$", "DELETE", function(request)
    local ok, token = pcall(string.match, request.headers["AUTHORIZATION"], "Bearer (.+)")
    if not ok or token == nil or not tokens:isValid(token) then
        return 403, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
    end
    if posts:delete({["id"] = request.parameters["id"]}) then
        return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
    end 
    return 500, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
end)

router:setCallback("^/tokens/?$", "POST", function(request)
    local ok, login = pcall(json.decode, request.body)
    if not ok then
        return 400, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
    end
    if login.id == settings["admin.id"] and login.password == settings["admin.password"] then
        return 200, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, json.encode(tokens:create())
    end 
    return 403, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
end)

router:setCallback("^/backup$", "GET", function(request)
    local ok, token = pcall(string.match, request.headers["AUTHORIZATION"], "Bearer (.+)")
    if not ok or token == nil or not tokens:isValid(token) then
        return 403, {["Content-Type"] = "application/json; charset=utf8", ["Access-Control-Allow-Origin"] = "*"}, "\"\""
    end
    return 200, {["Content-Type"] = "application/octet-stream", ["Content-Disposition"] = "attachment; filename='BACKUP.db'", ["Access-Control-Allow-Origin"] = "*"}, io.open(settings["database"], "r")
end)
 

router:setCallback(".*", "OPTIONS", function(request)
    return 200, {["Access-Control-Allow-Origin"] = "*", ["Access-Control-Allow-Methods"] = request.headers["ACCESS-CONTROL-REQUEST-METHOD"], ["Access-Control-Allow-Headers"] = request.headers["ACCESS-CONTROL-REQUEST-HEADERS"], ["Access-Control-Max-Age"] = "86400"}, "\"\"" -- Access-Control-Allow-Headers wildcard is not supported in chrome yet
end)

function onRequestFinish(client)
    client.request.parameters = urlQueryParser.parse(client.request.queryString)
    return router:route(client)
end

function onDestroy()
    posts:destroy()
end
