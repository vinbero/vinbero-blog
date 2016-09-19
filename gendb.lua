local sqlite = require 'lsqlite3'
local db = sqlite.open(arg[1])
if db:exec([[CREATE TABLE `posts`(`id` INTEGER PRIMARY KEY, `title` TINYTEXT, `text` TEXT, `cdate` DATE NOT NULL, `mdate` DATE NOT NULL, `private` TINYINT NOT NULL)]]) == 0 then
    print(arg[1] .. ' successfuly created')
else
    print(arg[1] .. ' not successfuly created')
end
db:close()
