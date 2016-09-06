math.randomseed(os.time())
requestMapping = {}
requestMapping['/'] = {}
requestMapping['/']['GET'] = function(request)
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
end

requestMapping['/access-token'] = {}
requestMapping['/access-token']['POST'] = function(request)
    if request.parameter['id'] == 'admin' and request.parameter['password'] == 'password' then
        return 200, {['Content-Type'] = 'text/html; charset=utf8'}, math.random()
    else
        return 401, {}, '401 Unauthorized'
    end
end

requestMapping['/error'] = {}
requestMapping['/error']['GET'] = function(request)
    return 500, {}, '500 Internal Server Error'
end

requestMapping['/empty'] = {}
requestMapping['/empty']['GET'] = function(request)
    return 200, {}
end

requestMapping['/hello'] = {}
requestMapping['/hello']['GET'] = function(request)
    return 200, {['Content-Type'] = 'text/html; charset=utf8'} , '<h1>Hello World</h1>'
end

requestMapping['/image'] = {}
requestMapping['/image']['GET'] = function(request)
    local file = assert(io.open('tux.jpg', 'r'))
    local body = file:read('*a')
    file:close()
    return 200, {['Content-Type'] = 'image/jpeg'}, body
end

function onRequestStart(request)
end

function onHeadersFinish(request)
end

function getContentLength(request)
    return request['CONTENT_LENGTH']
end

function onBodyChunk(request, body_chunk)
    print('onBodyChunk ' .. body_chunk)
    request.body = request.body .. body_chunk
end

function onBodyFinish(request)
    print(request.body)
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
    if requestMapping[request.pathInfo] ~= nil and requestMapping[request.pathInfo][request.method] ~= nil then
        return requestMapping[request.pathInfo][request.method](request)
    end
    return 404, {['Content-Type'] = 'text/html; charset=utf8'}, '404 Not Found'
end
