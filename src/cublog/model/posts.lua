local _M = {}

local sqlite = require "lsqlite3"
local settings = require "cublog.model.settings".Settings.new()
_M.Posts = {}
_M.Posts.__index = _M.Posts

function _M.Posts.new()
    local self = setmetatable({}, _M.Posts)
    local file = io.open(settings["DATABASE"])
    if file == nil then
       error("Databse not found") 
    end
    file:close()
    self.db = sqlite.open(settings["DATABASE"])
    return self
end

function _M.Posts:create(post)
    local insertStatement = self.db:prepare("INSERT INTO `posts`(`title`, `text`, `cdate`, `mdate`, `private`) VALUES($title, $text, DATE('now', 'localtime'), DATE('now', 'localtime'), $private)")
    insertStatement:bind_names(post)
    insertStatement:step()
    insertStatement:reset()
    local selectStatement = self.db:prepare("SELECT LAST_INSERT_ROWID() FROM `posts`")
    for row in selectStatement:rows() do
        selectStatement:reset()
        return row[1]
    end
    return nil 
end

function _M.Posts:get(post)
    local selectStatement = self.db:prepare("SELECT `id`, `title`, `text`, `cdate`, `mdate`, `private` FROM `posts` WHERE `id` = $id")
    selectStatement:bind_names(post)
    for row in selectStatement:nrows() do
        selectStatement:reset()
        return row
    end
    return nil 
end

function _M.Posts:getAll()
    local selectStatement = self.db:prepare("SELECT `id`, `title`, `cdate`, `mdate`, `private` FROM `posts`")
    local rows = {}
    for row in selectStatement:nrows() do
        table.insert(rows, row)
    end
    selectStatement:reset()
    return rows
end

function _M.Posts:update(post)
    local updateStatement = self.db:prepare("UPDATE `posts` SET `title` = $title, `text` = $text, `mdate` = DATE('now', 'localtime'), `private` = $private WHERE `id` = $id")
    updateStatement:bind_names(post)
    local status = updateStatement:step() == sqlite.DONE
    updateStatement:reset()
    return status
end

function _M.Posts:delete(post)
    local deleteStatement = self.db:prepare("DELETE FROM `posts` WHERE `id` = $id")
    deleteStatement:bind_names(post)
    local status = deleteStatement:step() == sqlite.DONE
    deleteStatement:reset()
    return status
end

function _M.Posts:destroy()
    self.db:close()
end

return _M
