local filters = require("devplus.setup").config.filters
local cache = require("devplus.tasks.cache")
local utils = require("devplus.tasks.utils")
local decoder = require("devplus.tasks.decoder")
local config = require("devplus.setup").config

---@class TaskBuffer
---@field bufnrs table<number, number>
---@field init function
local M = {}

---@type table<number, number>
M.buffers = {}

function M.ingest()
    local filts = utils.chain_from_iterable(filters)
    for idx, filter in ipairs(filts) do
        for _, task in ipairs(cache.new_entries) do
            if filter(task) then
                vim.api.nvim_buf_set_lines(M.buffers[idx], -1, -1, false, decoder.buffer(task))
            end
        end
    end
end

function M.init()
    for _, _ in pairs(filters) do
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
        vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
        config.buffer_keymaps(buf)
        table.insert(M.buffers,buf)
    end
end

return M
