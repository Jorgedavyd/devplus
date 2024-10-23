local M = {}

---sorter.default: Default sorter for telescope based on due_date, priority,
---start_date.
---@param task Task
---@return osdate
function M.default(task)
    return task.due_date
end

return M
