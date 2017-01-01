local _M = {}
local sqlite = require "lsqlite3"
local settings = require "cublog.model.settings".new()

_M.__index = _M

function _M.new()
    local self = setmetatable({}, _M)
    local file = io.open(settings["DATABASE"])
    if file == nil then
       error("Databse not found") 
    end
    file:close()
    self.db = sqlite.open(settings["DATABASE"])
    return self
end

function _M:create(post)
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

function _M:get(post)
    local selectStatement = self.db:prepare("SELECT `id`, `title`, `text`, `cdate`, `mdate`, `private` FROM `posts` WHERE `id` = $id")
    selectStatement:bind_names(post)
    for row in selectStatement:nrows() do
        selectStatement:reset()
        if row.private == 1 then
            row.private = true
        else
            row.private = false
        end
        return row
    end
    return nil 
end

function _M:getAll(includingPrivate)
    local selectStatement = self.db:prepare("SELECT `id`, `title`, `text`, `cdate`, `mdate`, `private` FROM `posts`")
    local rows = {}
    for row in selectStatement:nrows() do
        if row.private == 1 then
            row.private = true
        else
            row.private = false
        end
        if row.private == false or (row.private == true and includingPrivate == true) then
            table.insert(rows, row)
        end
    end
    selectStatement:reset()
    return rows
end

function _M:update(post)
    local updateStatement = self.db:prepare("UPDATE `posts` SET `title` = $title, `text` = $text, `mdate` = DATE('now', 'localtime'), `private` = $private WHERE `id` = $id")
    updateStatement:bind_names(post)
    local status = updateStatement:step() == sqlite.DONE
    updateStatement:reset()
    return status
end

function _M:delete(post)
    local deleteStatement = self.db:prepare("DELETE FROM `posts` WHERE `id` = $id")
    deleteStatement:bind_names(post)
    local status = deleteStatement:step() == sqlite.DONE
    deleteStatement:reset()
    return status
end

function _M:destroy()
    self.db:close()
end

return _M
