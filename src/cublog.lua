local cubelua = require 'cubelua'
local router = cubelua.Router.new()
local posts = require 'cublog.model.posts'.Posts.new()
local json = require 'json'

router:setCallback('^/posts$', 'POST', function(request)
    return 200, {['Content-Type'] = 'application/json; charset=utf8'}, posts:create(request.parameter['title'], request.parameter['text'], request.parameter['private'])
end)

router:setCallback('^/posts$', 'GET', function(request)
    return 200, {['Content-Type'] = 'application/json; charset=utf8'}, json.encode(posts:getAll()) 
end)

router:setCallback('^/posts/(?<id>\\d+)$', 'GET', function(request)
    return 200, {['Content-Type'] = 'application/json; charset=utf8'}, json.encode(posts:get(request.parameter['id']))
end)

router:setCallback('^/posts/(?<id>\\d+)$', 'PUT', function(request)
    if posts:update(request.parameter['id'], request.parameter['title'], request.parameter['text'], request.parameter['private']) then
        return 200, {['Content-Type'] = 'application/json; charset=utf8'}, 'true'
    else
        return 200, {['Content-Type'] = 'application/json; charset=utf8'}, 'false'
    end
end)

router:setCallback('^/posts/(?<id>\\d+)$', 'DELETE', function(request)
    if posts:delete(request.parameter['id']) then
        return 200, {['Content-Type'] = 'application/json; charset=utf8'}, 'true'
    else
        return 200, {['Content-Type'] = 'application/json; charset=utf8'}, 'false'
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
    request.parameter = {}
    if request.queryString ~= nil then
        for pair in string.gmatch(request.queryString, '([^&]+)') do
            for key, value in string.gmatch(pair, '([^=]+)=([^=]+)') do
                request.parameter[key] = value
            end
        end
    end
    return router:route(request)
end
