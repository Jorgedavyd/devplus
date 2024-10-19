local queue = require("devplus.database.queue")

---@class Cache
---@field history table<number, Task>
local M = {}

---@type table<number, Task>
M.history = {}

---cache.append: Adds the tasks to the buffer
---if they don't exist at cache. Additionally creates
---some ingestion to the database.
---@param buf_tasks table<number, Task>
---@return nil
function M.append(buf_tasks)
    for _, new_task in ipairs(buf_tasks) do
        local flag = 0
        for _, old_task in ipairs(M.history) do
            if old_task then
                if old_task == new_task then
                    flag = 1
                    break
                end
            end
        end
        if flag == 1 then
            table.insert(M.history, new_task)
        end
    end
end

return M
