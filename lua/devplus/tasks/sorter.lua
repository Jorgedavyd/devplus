local M = {}

---@param task Task
---@return integer
function M.default(task)
    return task.due_date
end

return M
