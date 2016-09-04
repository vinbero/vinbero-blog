requestMapping = {}
requestMapping['']  = function(client)
    local body = function()
        coroutine.yield('<h1>Hello World!</h1>')
        for k, v in pairs(client) do
            coroutine.yield('<h2>' .. k .. ': ' .. v .. '</h2>')
        end
    end
    return 200, {['Content-Type'] = 'text/html; charset=utf8'}, body
end

requestMapping['/access-token'] = {}
requestMapping['/access-token']['POST'] = function(client)
    return 200, {['Content-Type'] = 'text/html; charset=utf8'}, ''
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
end

function onRequestFinish(client)
    if requestMapping[client['PATH_INFO']] ~= nil and requestMapping[client['PATH_INFO']][client['REQUEST_METHOD']] ~= nil then
        return requestMapping[client['PATH_INFO']][client['REQUEST_METHOD']](client)
    end
    return requestMapping[''](client)
end
