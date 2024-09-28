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

function M.create()
    for name, _ in pairs(config.categories) do
        local lines = find.grep(name)
        find.create(lines, M.buf)
    end
end

---@param name string
---@return number
function M.init(name)
    M.buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_name(M.buf, name)
    api.nvim_buf_set_option(M.buf, 'modifiable', false)
    api.nvim_buf_set_option(M.buf, 'buftype', 'nofile')
    retu
    M.create()
    prettier.init(M.buf)
    config.keymaps()
end

---@param tasks table<number, Task>
function M.update(tasks)
    local buf_tasks = M.treat(tasks)
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

function M.reset()
    api.nvim_buf_delete(M.buf)
    M.init()
end

return M
