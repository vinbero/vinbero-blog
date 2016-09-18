local cubelua = require 'cubelua'
local router = cubelua.Router.new()
local settings = require 'cublog.model.settings'.Settings.new()
local posts = require 'cublog.model.posts'.Posts.new()
local tokens = require 'cublog.model.tokens'.Tokens.new()
local json = require 'cjson'

router:setCallback('^/posts$', 'POST', function(request)
    local status, post = pcall(json.decode, request.body)
    if status == false then
        return 400, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'null'
    end
    return 200, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, posts:create(post.title, post.text, post.private)
end)

router:setCallback('^/posts$', 'GET', function(request)
    return 200, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, json.encode(posts:getAll()) 
end)

router:setCallback('^/posts/(?<id>\\d+)$', 'GET', function(request)
    local post = posts:get(request.parameters['id'])
    if post ~= nil then
        return 200, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, json.encode(posts:get(request.parameters['id']))
    end 
    return 400, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'null'
end)

router:setCallback('^/posts/(?<id>\\d+)$', 'PUT', function(request)
    local status, post = pcall(json.decode, request.body)
    if status == false then
        return 400, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'null'
    end
    if posts:update(post.id, post.title, post.text, post.private) then
        return 200, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'true'
    end
    return 500, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'false'
end)

router:setCallback('^/posts/(?<id>\\d+)$', 'DELETE', function(request)
    if posts:delete(request.parameters['id']) then
        return 200, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'true'
    end 
    return 500, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'false'
end)

router:setCallback('^/tokens$', 'POST', function(request)
    local status, login = pcall(json.decode, request.body)
    if status == false then
        return 400, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'null'
    end
    if login.id == settings['ADMIN-ID'] and login.password == settings['ADMIN-PASSWORD'] then
        return 200, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, json.encode(tokens:create())
    end 
    return 403, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'null'
end)

function getContentLength(request)
    return request.contentLength
end

function onBodyChunk(request, bodyChunk)
    request.body = request.body .. bodyChunk
end

function onRequestFinish(request)
    cubelua.parseQueryString(request)
    return router:route(request)
end

function onDestroy()
    posts:destroy()
end
