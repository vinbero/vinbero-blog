local cubelua = require 'cubelua'
local router = cubelua.Router.new()
local posts = require 'cublog.model.posts'.Posts.new()
local json = require 'json'

router:setCallback('^/posts$', 'POST', function(request)
    local post = json.decode(request.body)
    return 200, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, posts:create(post.title, post.text, post.private)
end)

router:setCallback('^/posts$', 'GET', function(request)
    return 200, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, json.encode(posts:getAll()) 
end)

router:setCallback('^/posts/(?<id>\\d+)$', 'GET', function(request)
    local post = posts:get(request.parameters['id'])
    if post ~= nil then
        return 200, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, json.encode(posts:get(request.parameters['id']))
    else
        return 400, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'null'
    end
end)

router:setCallback('^/posts/(?<id>\\d+)$', 'PUT', function(request)
    local post = json.decode(request.body);
    if posts:update(post.id, post.title, post.text, post.private) then
        return 200, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'true'
    else
        return 500, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'false'
    end
end)

router:setCallback('^/posts/(?<id>\\d+)$', 'DELETE', function(request)
    if posts:delete(request.parameters['id']) then
        return 200, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'true'
    else
        return 500, {['Content-Type'] = 'application/json; charset=utf8', ['Access-Control-Allow-Origin'] = '*'}, 'false'
    end
end)

function getContentLength(request)
    return request.contentLength
end

function onBodyChunk(request, body_chunk)
    request.body = request.body .. body_chunk
end

function onRequestFinish(request)
    cubelua.parseQueryString(request)
    return router:route(request)
end

function onDestroy()
    posts:destroy()
end
