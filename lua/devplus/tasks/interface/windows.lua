local config = require("setup").config.windows
local async = require("plenary.async").async
local await = require("plenary.async").await
local filter = require("filter")
local buffer = require("buffer")
local logs = require("logs")
local api = vim.api

---@alias WinMatrix table<number, table<number, table<string, string|number>>>
---@class Windows
---@field config Config
---@field setWindows function
local M = {}

M.config = config

---@private
---@param opts Config | table <number, Filter>
---@return nil
function M.assert(opts)
    if type(opts[1]) == "table" then
        for _, ops in pairs(opts) do
            return M.assert(ops)
        end
    elseif type(opts[1]) == "function" then
        for idx, func in ipairs(opts) do
            if !filter.isFilterFunction(func) then
                logs.error("Not valid function at function" .. idx .. " in windows opts, expected a function(task) -> boolean")
            end
        end
    else
        logs.error("Not valid optsuration table for windows")
    end
end

---@private
---@param opts Config
---@return nil
function M.matrixAssert(opts)
    if type(opts[0]) == "table" then
        for i=1,#opts - 1 do
            if (#(opts[i]) ~= #(opts[i+1])) then
                logs.error("Config should be a grid of NxM with no void spaces.")
            end
        end
    end
end

---@private
---@param opts Config
---@return WinMatrix
function M.getWindowOpts(opts, idx, row_size)
    local positions = {}
    local range = #opts
    if type(opts[1]) == "table" then
        assert(type(idx) == "nil", "Not valid keyword idx for nested table")
        assert(type(row_size) == "nil", "Not valid keyword len for nested table")
        for i=1,range do
            table.insert(positions, M.getWindowOpts(opts, i, range))
        end
    else
        local height, width = vim.o.lines, math.floor(vim.o.columns * 5 / 8)
        local shift = vim.o.columns - width
        for i=1,range do
            table.insert(positions, {
                relative = 'editor',
                width = math.floor(height / row_size),
                height = math.floor(width / range),
                row = idx,
                col = shift + i,
                style = 'minimal',
                border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
            })
        end
    end
    return positions
end

---@return nil
function M.setWindows()
    M.assert(config)
    local tasks = {}
    for _, opts in ipairs(M.getWindowOpts(config)) do
        table.insert(tasks, async(function ()
            await(vim.schedule_wrap(function ()
                local win = vim.api.nvim_open_win(buffer.buf, true, opts)
                api.nvim_win_set_buf(win, buffer.buf)
                --- filter
            end)
        end)))
    end
    return tasks
end

return M
