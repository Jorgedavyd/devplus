---@class Utils
local M = {}

function M.warning(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "devplus" })
end

function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "devplus" })
end

return M
