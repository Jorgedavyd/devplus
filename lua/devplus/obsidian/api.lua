local parser = require("parser")
local config = require("setup").config

local M = {}

---@private
---@return string
function M.getPath()
    return vim.fn.resolve(config.vault .. config.project .. "todo.md");
end

return M
