local _M = {}

local mysql = require 'luasql.mysql'

_M.Posts = {}
_M.Posts.__index = _M.Posts

function _M.Posts.new()
    local self = setmetatable({}, _M.Posts)
    self.mysqlEnv = mysql.mysql()
    self.mysqlCon = self.mysqlEnv:connect('cublog', 'root', 'root')
    return self
end

function _M.Posts:create(title, text, private)
    local status, errorString = self.mysqlCon:execute("INSERT INTO `posts`(`title`, `text`, `cdate`, `mdate`, `private`) VALUES('" .. self.mysqlCon:escape(title) .. "', '" .. self.mysqlCon:escape(text) .. "', " .. "CURDATE(), CURDATE(), " .. self.mysqlCon:escape(private) .. ")")
    local cursor, errorString = self.mysqlCon:execute("SELECT LAST_INSERT_ID() from `posts`")
    local id = cursor:fetch()
    cursor:close()
    return id
end

function _M.Posts:get(id)
    local cursor, errorString = self.mysqlCon:execute("SELECT `id`, `title`, `text`, `cdate`, `mdate`, `private` FROM `posts` WHERE `id` = " .. self.mysqlCon:escape(id))
    local row = cursor:fetch({}, 'a')
    cursor:close()
    return row
end

function _M.Posts:getAll()
    local cursor, errorString = self.mysqlCon:execute("SELECT `id`, `title`, `cdate`, `mdate`, `private` FROM `posts`")
    local rows = {}
    local row = cursor:fetch({}, 'a')
    while row do
        table.insert(rows, row)
        row = cursor:fetch({}, 'a')
    end
    cursor:close()
    return rows
end

function _M.Posts:update(id, title, text, private)
    local status, errorString = self.mysqlCon:execute("UPDATE `posts` set `title` = '" .. self.mysqlCon:escape(title) .. "', `text` = '" .. self.mysqlCon:escape(text) .. "', `mdate` = CURDATE(), `private` = " .. self.mysqlCon:escape(private) .. " where id = " .. self.mysqlCon:escape(id))
    if status == 1 then
        return true
    else
        return false
    end
end

function _M.Posts:delete(id)
    local status, errorString = self.mysqlCon:execute("DELETE FROM `posts` where `id` = '" .. self.mysqlCon:escape(id) .. "'")
    if status == 1 then
        return true
    else
        return false
    end
end

function _M.Posts:destroy()
    self.mysqlCon:close()
    self.mysqlEnv:close()
end

return _M
