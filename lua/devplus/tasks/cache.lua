---@class Cache
---@field history table<number, Task>
local M = {}

---@type Task[]
M.history = {}

---cache.append: Adds the tasks to the buffer
---if they don't exist at cache. Additionally creates
---some ingestion to the database.
---@param tasks Task[]
---@return nil
function M.append(tasks)
    for _, new_task in ipairs(tasks) do
        local flag = 0
        for _, old_task in ipairs(M.history) do
            if old_task then
                if old_task == new_task then
                    flag = 1
                    break
                end
            end
        end
        if flag == 0 then
            table.insert(M.history, new_task)
            _G.db.tasks.queue.append(new_task)
            _G.obsidian.append(new_task)
        end
    end
end

_G.cache = M
