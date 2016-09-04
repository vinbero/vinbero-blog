pathMapping = {}
pathMapping['/'] = function(client)
    local body = function()
        coroutine.yield('<h1>Hello World!</h1>')
        for k, v in pairs(client) do
            coroutine.yield('<h2>' .. k .. ': ' .. v .. '</h2>')
        end
    end
    return 200, {['Content-Type'] = 'text/html; charset=utf8'}, body
end

pathMapping['/hello'] = function(client)
    return 200, {['Content-Type'] = 'text/html; charset=utf8'} , '<h1>Hello World</h1>'
end

function onRequestStart(client)
end

function onHeadersFinish(client)
end

function getContentLength(client)
    return client['CONTENT_LENGTH']
end

function onBodyChunk(client, body_chunk)
    client['BODY'] = client['BODY'] .. body_chunk
end

function onBodyFinish(client)
    print(client['BODY'])
end

function onRequestFinish(client)
    if pathMapping[client['PATH_INFO']] ~= nil then
        return pathMapping[client['PATH_INFO']](client)
    end
    return 400, {['Content-Type'] = 'text/html; charset=utf8'}, '<h1>404 Not Found</h1>'
end
