local api = vim.api

---@class TrackerBuffer
---@field init function
---@field virtual function
local M = {}

---@type number|nil
M.buf = nil

function M.init()
    M.buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_name(M.buf, "Tracker")
    api.nvim_buf_set_option(M.buf, 'modifiable', false)
    api.nvim_buf_set_option(M.buf, 'buftype', 'nofile')
end

function M.reset()
    api.nvim_buf_delete(M.buf)
    M.init()
end

return M
