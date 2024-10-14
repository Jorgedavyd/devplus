local config = require("devplus.setup").config.tasks
local logs = require("devplus.logs")
local icons = require("devplus.obsidian.taskMotes")
---@class Encoder
---@field obsidian function
---@field inline function
local M = {}

---@private
---@param task string
---@param pattern string
---@return Task|nil
function M.default(task, pattern)
    local category, due_date, priority, description = string.match(task, pattern)
    if category and due_date and priority and description then
        return {
            category = category:upper(),
            due_date = os.date(config.time_format, due_date),
            priority = priority:lower(),
            description = description
        }
    end
    logs.error("Couldn't encoder the data at Task Encoder")
end

---@param task string
---@return Task|nil
function M.obsidian(task)
    return M.default(task, ("- [ ] (%a+) %b[](%a+) %b[](%a+) (.+)"):format())
end

---@param task string
---@return Task|nil
function M.inline(task)
    return M.default(task, "(%a+) (%a+) (%a+) (.+)")
end

local function table_invert(t)
   local s={}
   for k,v in pairs(t) do
     s[v]=k
   end
   return s
end

---@param task string
---@return Task|nil
function M.buffer(task)
    local category, priority, due_date, description = string.match(task, "(%a+)(%a+)(%a+)(.+)")
    if category and priority and due_date and description then
        category = table_invert(config.categories)[category]
        priority = table_invert(icons.priority)[priority]
        return {
            category = category:upper(),
            due_date = os.date(config.time_format, due_date),
            priority = priority:lower(),
            description = description
        }
    end
end

return M
