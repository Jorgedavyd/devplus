local config = require("devplus.setup").config.tasks
local windows = require("devplus.tasks.interface.windows")
local buffer = require("devplus.tasks.interface.buffer")
local async = require("plenary.async").async
local await = require("plenary.async").await
local filter = require("devplus.tasks.interface.filter")
local prettier = require("devplus.tasks.interface.front")

local api = vim.api

local M = {}

---@type table<number, table<string, number>>
M.interface = {}

local function chain_from_iterable(iterables)
    local co = coroutine.create(function()
        for _, iterable in ipairs(iterables) do
            for _, value in ipairs(iterable) do
                coroutine.yield(value)
            end
        end
    end)

    return function()
        local status, value = coroutine.resume(co)
        if status then return value else return nil end
    end
end

---@return nil
function M.init()
    windows.assert(config.windows)
    local configs = windows.getWindowsConfig(config.windows.filters)
    if type(configs[0]) == "table" then
        configs = chain_from_iterable(configs)
    end
    local tasks = {}
    for _, config in configs do
        table.insert(tasks, async(function ()
            await(vim.schedule_wrap(function ()
                local buf = buffer.create()
                local win = api.nvim_open_win(buf, true, config)
                api.nvim_win_set_buf(win, buf)
                local filtered = filter.create(buf, config.filter)
                buffer.append(buf, filtered)
                table.insert(M.interface, {
                    win = win,
                    buf = buf
                })
            end)
        end)))
    end
end

---@param tasks table<number, Task>
function M.update(tasks, filters)
    for idx, opts in ipairs(M.interface) do
        for _, task in pairs(tasks) do
            if filters[idx](task) then
                buffer.append(opts.buf, task)
                prettier.scan(opts.buf)
            end
        end
    end
end

return M
