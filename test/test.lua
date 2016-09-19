local cubelua = require 'cubelua'
local router = cubelua.Router.new()
router:setCallback('^/$', 'GET', function(request)
   local body = function()
       coroutine.yield('<h1>Hello World!</h1>')
       for key, value in pairs(request) do
           if type(value) == 'string' then
               coroutine.yield('<h2>' .. key .. ': ' .. value .. '</h2>')
           end
       end
       for key, value in pairs(request.headers) do
           coroutine.yield('<h2>' .. key .. ': ' .. value .. '</h2>')
       end
   end
   return 200, {['Content-Type'] = 'text/html; charset=utf8'}, body
end)

math.randomseed(os.time())
router:setCallback('^/access-token', 'POST', function(request)
    if request.parameter['id'] == 'admin' and request.parameter['password'] == 'password' then
        return 200, {['Content-Type'] = 'text/html; charset=utf8'}, math.random()
    end 
    return 401, {}, '401 Unauthorized'
end)

router:setCallback('^/error', 'GET', function(request)
    return 500, {}, '500 Internal Server Error'
end)

router:setCallback('^/empty', 'GET', function(request)
    return 200, {}
end)

router:setCallback('^/hello', 'GET', function(request)
    return 200, {['Content-Type'] = 'text/html; charset=utf8'}, '<h1>Hello World</h1>'
end)

router:setCallback('^/image', 'GET', function(request)
    local file = assert(io.open('tux.jpg', 'r'))
    local body = file:read('*a')
    file:close()
    return 200, {['Content-Type'] = 'image/jpeg'}, body
end)

router:setCallback('^/param/(?<num>\\d+)$', 'GET', function(request)
    local body = function()
        for key, value in pairs(request.parameter) do
            coroutine.yield('<h2>' .. key .. ': ' .. value .. '</h2>')
        end
    end
    return 200, {['Content-Type'] = 'text/html; charset=utf8'}, body
end)

function getContentLength(request)
    return request.contentLength
end

function onBodyChunk(request, bodyChunk)
    request.body = request.body .. bodyChunk
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
