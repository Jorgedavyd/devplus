---@class Cache
---@field history table<number, Task>
local M = {}

---@type table<number, Task>
M.history = {}

M.new_entries = {}

---cache.append: Appends the Task into the cache.
---@param task Task
function M.append(task)
    table.insert(M.history, task)
end

function M.ingest(buf_tasks)
    for _, buf_task in ipairs(buf_tasks) do
        for _, task in ipairs(M.history) do
            if buf_task == task then
                break
            end
        end
        table.insert(M.new_entries, buf_task)
    end
end

return M
