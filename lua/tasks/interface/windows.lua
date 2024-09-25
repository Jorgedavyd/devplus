local logs = require("logs")
local buffer = require("buffer")
local filter = require("filter")
local api = vim.api

---@alias WinMatrix table<number, table<number, table<string, string|number>>>
---@class Windows
---@field config Config
---@field setWindows function
local M = {}

---@type Config
M.config = {}

---@private
---@param config Config | table <number, Filter>
---@return nil
function M.assert(config)
    if type(config[1]) == "table" then
        for _, ops in pairs(config) do
            return M.assert(ops)
        end
    elseif type(config[1]) == "function" then
        for idx, func in ipairs(config) do
            if !filter.isFilterFunction(func) then
                logs.error("Not valid function at function" .. idx .. " in windows config, expected a function(task) -> boolean")
            end
        end
    else
        logs.error("Not valid configuration table for windows")
    end
end

---@private
---@param config Config
---@return nil
function M.matrixAssert(config)
    if type(config[0]) == "table" then
        for i=1,#config - 1 do
            if (#(config[i]) ~= #(config[i+1])) then
                logs.error("Config should be a grid of NxM with no void spaces.")
            end
        end
    end
end

---@private
---@param config Config
---@return WinMatrix
function M.getWindowOpts(config, idx, row_size)
    local positions = {}
    local range = #config
    if type(config[1]) == "table" then
        assert(type(idx) == "nil", "Not valid keyword idx for nested table")
        assert(type(row_size) == "nil", "Not valid keyword len for nested table")
        for i=1,range do
            table.insert(positions, M.getWindowOpts(config, i, range))
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
    M.assert(M.config)
    for idx, opts in ipairs(M.getWindowOpts(M.config)) do
        api.nvim_win_set_buf(idx, buffer.buf)
        local win = vim.api.nvim_open_win(buffer.buf, true, opts)

    end
end

return M
