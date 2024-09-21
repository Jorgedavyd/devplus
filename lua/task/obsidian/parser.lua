local motes = require("taskMotes")

local M = {}


---@private
---@param due_date string
---@param priority string
---@param description string
---@return string
function M.defaultParser(due_date, priority, description)
    return ("- [ ] %s %s%s %s%s"):format(description, motes.due_date, due_date, motes.priority[priority] ,priority)
end

---@param task table [[string]: string]
---@return nil
function M.assert(task)
    assert (task.priority)
    assert (task.description)
    assert (task.due_date)
end

---@param task table [[string]: string]
---@return string
function M.task(task)
    M.assert(task)
    return M.defaultParser(task.due_date, task.priority, task.description)
end


return M
