local obsidian = require("devplus.obsidian.parser")
local icons = require("devplus.obsidian.taskMotes")
local config = require("devplus.setup").config.tasks
---@class Decoder
---@field obsidian function
---@field inline function
local M = {}

---@param task Task
---@return string
function M.obsidian(task)
    return obsidian.singleTaskParser(task.due_date, task.priority, task.description, task.category)
end

---@param task Task
function M.inline(task)
    return ("%s %s%s %s%s %s"):format(
        task.category,
        icons.due_date[task.due_date],
        task.due_date,
        icons.priority[task.priority],
        task.priority,
        task.description
    )
end

---@param task Task
function M.buffer(task)
    return ("%s %s %s"):format(config.categories[task.category], task.due_date, task.description)
end

return M

