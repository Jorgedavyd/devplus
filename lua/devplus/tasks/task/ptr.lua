local prettier = require("tasks.interface.front")
---@class PtrTask
---@field init function
local M = {}

---@private
function M.fromCache()
end

---@private
---@param data Task
function M.fromDatabase(data)
end

return M
