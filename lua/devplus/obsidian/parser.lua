local todo_template = require("template").todo
local motes = require("taskMotes")
local config = require("setup").config.tasks

---@class ObsidianParser
---@field singleTaskParser function
---@field assert function
---@field task function
---@field singleBlockParser function
local M = {}

---@param due_date string
---@param priority string
---@param description string
---@return string
function M.singleTaskParser(due_date, priority, description)
    return ("- [ ] %s %s%s %s%s"):format(description, motes.due_date, due_date, motes.priority[priority] ,priority)
end

---@param task table <string,string>
---@return nil
function M.assert(task)
    assert (task.priority and task.description and task.due_date)
end

---@param task table <string,string>
---@return string
function M.task(task)
    M.assert(task)
    return M.singleTaskParser(task.due_date, task.priority, task.description)
end

---@param s string
---@param match string
---@param value ?string
function string.replace(s,match,value)
    value = value or ""
    local i, j = string.find(s, match)
    if i and j then
         return string.sub(s, 0, i) .. value .. string.sub(s, j)
    else
        return
    end

end

---@param task table <string, string>
---@return table <string, string>
function M.singleBlockParser(task)
    local block = {}
    for _, line in ipairs(todo_template) do
        local group = string.match(line, "{{(.+?)}}")
        if group then
            string.replace(line, task[todo_template[group[0]]])
        end
        table.insert(block, line)
    end
    return block
end

return M
