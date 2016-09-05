math.randomseed(os.time())
requestMapping = {}
requestMapping['/'] = {}
requestMapping['/']['GET'] = function(client)
    local body = function()
        coroutine.yield('<h1>Hello World!</h1>')
        for key, value in pairs(client) do
            if type(value) == 'string' then
                coroutine.yield('<h2>' .. key .. ': ' .. value .. '</h2>')
            end
        end
    end
    return 200, {['Content-Type'] = 'text/html; charset=utf8'}, body
end

requestMapping['/access-token'] = {}
requestMapping['/access-token']['POST'] = function(client)
    if client.parameter['id'] == 'admin' and client.parameter['password'] == 'password' then
        return 200, {['Content-Type'] = 'text/html; charset=utf8'}, math.random()
    else
        return 401, {}, '401 Unauthorized'
    end
end

requestMapping['/error'] = {}
requestMapping['/error']['GET'] = function(client)
    return 500, {}, '500 Internal Server Error'
end

requestMapping['/empty'] = {}
requestMapping['/empty']['GET'] = function(client)
    return 200, {}
end

requestMapping['/hello'] = {}
requestMapping['/hello']['GET'] = function(client)
    return 200, {['Content-Type'] = 'text/html; charset=utf8'} , '<h1>Hello World</h1>'
end

requestMapping['/image'] = {}
requestMapping['/image']['GET'] = function(client)
    local file = assert(io.open('tux.jpg', 'r'))
    local body = file:read('*a')
    file:close()
    return 200, {['Content-Type'] = 'image/jpeg'}, body
end

function onRequestStart(client)
end

function onHeadersFinish(client)
end

function getContentLength(client)
    return client['CONTENT_LENGTH']
end

function onBodyChunk(client, body_chunk)
    print('onBodyChunk ' .. body_chunk)
    client['BODY'] = client['BODY'] .. body_chunk
end

function onBodyFinish(client)
    print(client['BODY'])
    client['QUERY_STRING'] = client['BODY']
end

function onRequestFinish(client)
    print('onRequestFinish')
    client.parameter = {}
    if client['QUERY_STRING'] ~= nil then
        for pair in string.gmatch(client['QUERY_STRING'], '([^&]+)') do
            for key, value in string.gmatch(pair, '([^=]+)=([^=]+)') do
                client.parameter[key] = value
            end
        end
    end
    print(client['PATH_INFO'])
    if requestMapping[client['PATH_INFO']] ~= nil and requestMapping[client['PATH_INFO']][client['REQUEST_METHOD']] ~= nil then
        return requestMapping[client['PATH_INFO']][client['REQUEST_METHOD']](client)
    end
    return 404, {['Content-Type'] = 'text/html; charset=utf8'}, '404 Not Found'
end
