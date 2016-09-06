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
    request['BODY'] = request['BODY'] .. body_chunk
end

function onBodyFinish(request)
    print(request['BODY'])
    request['QUERY_STRING'] = request['BODY']
end

function onRequestFinish(request)
    print('onRequestFinish')
    request.parameter = {}
    if request['QUERY_STRING'] ~= nil then
        for pair in string.gmatch(request['QUERY_STRING'], '([^&]+)') do
            for key, value in string.gmatch(pair, '([^=]+)=([^=]+)') do
                request.parameter[key] = value
            end
        end
    end
    print(request['PATH_INFO'])
    if requestMapping[request['PATH_INFO']] ~= nil and requestMapping[request['PATH_INFO']][request['REQUEST_METHOD']] ~= nil then
        return requestMapping[request['PATH_INFO']][request['REQUEST_METHOD']](request)
    end
    return 404, {['Content-Type'] = 'text/html; charset=utf8'}, '404 Not Found'
end
