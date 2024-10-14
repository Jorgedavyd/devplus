---@class Task
---@field due_date number|nil
---@field category number|nil
---@field priority number|nil
---@field description string|nil
---@field file string|nil
---@field opts TaskOpts
local M = {}

---@class TaskOpts
---@field extmark_id number|nil
---@field checkmark_status boolean
M.opts = {}

return M
