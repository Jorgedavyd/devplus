local prettier = require("devplus.tasks.interface.front")
local config = require("devplus.setup").config.tasks
local find = require("devplus.tasks.scan")
local api = vim.api

---@class Buffer
---@field init function
---@field virtual function
local M = {}

---@type number|nil
M.buf = nil

function M.create()
    for name, _ in pairs(config.categories) do
        local lines = find.grep(name)
        find.create(lines, M.buf)
    end
end

function M.init()
    M.buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_name(M.buf, "Tasks")
    api.nvim_buf_set_option(M.buf, 'modifiable', false)
    api.nvim_buf_set_option(M.buf, 'buftype', 'nofile')
    M.create()
    prettier.init(M.buf)
    config.keymaps()
end

--- API

function M.reset()
    api.nvim_buf_delete(M.buf)
    M.init()
end

return M
