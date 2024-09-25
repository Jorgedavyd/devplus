local api = vim.api
---@class Buffer
---@field init function
---@field virtual function
local M = {}

---@type number|nil
M.buf = nil

function M.init()
    M.buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_name(M.buf, "Tasks")
    api.nvim_buf_set_option(M.buf, 'modifiable', false)
    api.nvim_buf_set_option(M.buf, 'buftype', 'nofile')
end

function M.reset()
    api.nvim_buf_delete(M.buf)
    M.init()
end

---@return nil
function M.prettify()
    local prettier = require("prettier")
    prettier.update(task)
end

return M
