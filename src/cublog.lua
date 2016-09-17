local cubelua = require 'cubelua'
local router = cubelua.Router.new()
local posts = require 'cublog.model.posts'.Posts.new()
local json = require 'json'

router:setCallback('^/posts$', 'POST', function(request)
    return 200, {['Content-Type'] = 'application/json; charset=utf8'}, posts:create(request.parameters['title'], request.parameters['text'], request.parameters['private'])
end)

router:setCallback('^/posts$', 'GET', function(request)
    return 200, {['Content-Type'] = 'application/json; charset=utf8'}, json.encode(posts:getAll()) 
end)

router:setCallback('^/posts/(?<id>\\d+)$', 'GET', function(request)
    local post = posts:get(request.parameters['id'])
    if post ~= nil then
        return 200, {['Content-Type'] = 'application/json; charset=utf8'}, json.encode(posts:get(request.parameters['id']))
    else
        return 400, {['Content-Type'] = 'application/json; charset=utf8'}, 'null'
    end
end)

router:setCallback('^/posts/(?<id>\\d+)$', 'PUT', function(request)
    if posts:update(request.parameters['id'], request.parameters['title'], request.parameters['text'], request.parameters['private']) then
        return 200, {['Content-Type'] = 'application/json; charset=utf8'}, 'true'
    else
        return 500, {['Content-Type'] = 'application/json; charset=utf8'}, 'false'
    end
end)

router:setCallback('^/posts/(?<id>\\d+)$', 'DELETE', function(request)
    if posts:delete(request.parameters['id']) then
        return 200, {['Content-Type'] = 'application/json; charset=utf8'}, 'true'
    else
        return 500, {['Content-Type'] = 'application/json; charset=utf8'}, 'false'
    end
end)

function getContentLength(request)
    return request.contentLength
end

function onBodyChunk(request, body_chunk)
    request.body = request.body .. body_chunk
end

function onBodyFinish(request)
    request.queryString = request.body
end

function onRequestFinish(request)
    cubelua.parseQueryString(request)
    return router:route(request)
end

function onDestroy()
    posts:destroy()
end
