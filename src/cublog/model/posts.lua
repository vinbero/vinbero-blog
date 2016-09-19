local _M = {}

local sqlite = require 'lsqlite3'
local settings = require 'cublog.model.settings'.Settings.new()
_M.Posts = {}
_M.Posts.__index = _M.Posts

function _M.Posts.new()
    local self = setmetatable({}, _M.Posts)
    local file = io.open(settings['DATABASE'])
    if file == nil then
       error('Databse not found') 
    end
    file:close()
    self.db = sqlite.open(settings['DATABASE'])
    return self
end

function _M.Posts:create(title, text, private)
    if self.db:exec("INSERT INTO `posts`(`title`, `text`, `cdate`, `mdate`, `private`) VALUES('" .. title .. "', '" .. text .. "', " .. "DATE('now', 'localtime'), DATE('now', 'localtime'), " .. private .. ")") == 0 then
        for row in self.db:rows("SELECT LAST_INSERT_ROWID() FROM `posts`") do
            return row[1] 
        end
    end
    return nil 
end

function _M.Posts:get(id)
    for row in self.db:nrows("SELECT `id`, `title`, `text`, `cdate`, `mdate`, `private` FROM `posts` WHERE `id` = " .. id) do
        return row
    end
    return nil 
end

function _M.Posts:getAll()
    local rows = {}
    for row in self.db:nrows("SELECT `id`, `title`, `cdate`, `mdate`, `private` FROM `posts`") do
        table.insert(rows, row)
    end
    return rows
end

function _M.Posts:update(id, title, text, private)
    return self.db:exec("UPDATE `posts` SET `title` = '" .. title .. "', `text` = '" .. text .. "', `mdate` = DATE('now', 'localtime'), `private` = " .. private .. " WHERE `id` = " .. id) == 0
end

function _M.Posts:delete(id)
    return self.db:exec("DELETE FROM `posts` WHERE `id` = '" .. self.mysqlCon:escape(id) .. "'") == 0
end

function _M.Posts:destroy()
    self.db:close()
end

return _M
