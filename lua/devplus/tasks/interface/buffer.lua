local prettier = require("devplus.tasks.interface.front")
local decoder = require("devplus.tasks.task.decoder")
local config = require("devplus.setup").config.tasks
local find = require("devplus.tasks.grep")
local api = vim.api

---@class Buffer
---@field init function
---@field virtual function
local M = {}

---@type number|nil
M.buf = nil

function M.create(buf, filter)
    for name, _ in pairs(config.categories) do
        local lines = find.grep(name)
        find.create(lines, buf, filter)
    end
end

---@param name string
---@return number
function M.init(name)
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_name(buf, name)
    api.nvim_buf_set_option(buf, 'modifiable', false)
    api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    M.create(buf)
    prettier.init(buf)
    config.keymaps(buf)
end

---@private
---@param tasks Task
---@return table<number, string>
function M.treat(tasks)
    local buf_tasks = {}
    for _, task in ipairs(tasks) do
        table.insert(buf_tasks, decoder.buffer(task))
    end
    return buf_tasks
end
--- API

---@param lines table<number, string>
function M.append(buf, lines)
    api.nvim_buf_set_lines(buf, -1, -1, false, lines)
end


function M.reset(buf_name, bufnr)
    api.nvim_buf_delete(bufnr)
    M.init(buf_name)
end

return M
