local config = require("devplus.setup").config.tasks
---@class Encoder
---@field obsidian function
---@field inline function
local M = {}

---@private
---@param task string
---@param pattern string
---@return Task
function M.default(task, pattern)
    local group = string.match(task, pattern)
    local category = group[1]
    local due_date = os.date(config.time_format, group[2])
    local priority = group[3]
    local description = group[4]
    return {
        category = category:upper(),
        due_date = due_date,
        priority = priority:lower(),
        description = description
    }
end

---@param task string
---@return Task
function M.obsidian(task)
    return M.default(task, "")
end

---@param task string
---@return Task
function M.inline(task)
    return M.default(task, "")
end

---@param task string
---@return Task
function M.buffer(task)
    return M.default(task, "")
end

return M
