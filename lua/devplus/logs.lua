---@alias logs fun(msg: string): nil
---@class Logs
---@field warning logs
---@field error logs
local M = {}

---@type logs
function M.warning(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "devplus" })
end

---@type logs
function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "devplus" })
end

return M
