---@class Buffer
---@field init function
---@field virtual function
local M = {}

---@type buffer|nil
M.buf = nil

function M.init()
    M.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(M.buf, "Tasks")
    vim.api.nvim_buf_set_option(M.buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(M.buf, 'buftype', 'nofile')
end

---@return nil
function M.sign()
    local prettier = require("prettier")
end

return M
