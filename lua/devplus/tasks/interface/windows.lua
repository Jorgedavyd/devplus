local config = require("devplus.setup").config
local filter = require("devplus.tasks.interface.filter")
local logs = require("devplus.logs")

---@alias Config table<number, Filter> | table<number, table<number, Filter>>
---@alias WinMatrix table<number, string|number|Filter> | table<number, table<number, number|string|Filter>>
---@class Windows
---@field config Config
---@field setWindows function
local M = {}

---@private
---@param opts Config
---@return nil
function M.filter_assert(opts)
    for idx, ops in ipairs(opts) do
        if type(ops) == 'table' then
            M.filter_assert(ops)
        elseif type(ops) == 'function' then
            if !filter.isFilterFunction(ops) then
                logs.error("Not valid function at function" .. idx .. " in windows opts, expected a function(task) -> boolean")
            end
        end
    end
end

---@private
---@param opts table<string, string>
---@return nil
function M.config_assert(opts)
    for name, _ in pairs(opts) do
        local flag
        for _, value in {'style', 'border'} do
            if name == value then
                flag = 1
            end
        end
        if not flag then
            logs.error("Not valid argument %s for config, expected relative, style, border")
        end
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

---@return nil
function M.assert()
    M.filter_assert(config.windows.filters)
    M.config_assert(config.windows.config)
    M.matrixAssert(config.windows.filters)
end

function M.getWindowsConfig(filters, row_size, row, col_size, col)
    local opts = {}
    if type(filters) == 'table' then
        assert (type(col_size) == 'nil', "Not valid argument row_size")
        for i, op in ipairs(filters) do
            if row_size then
                table.insert(opts, M.getWindowsConfig(op, row_size, row, #filters, i))
            else
                table.insert(opts, M.getWindowsConfig(op, #filters, i))
            end
        end
        return opts
    elseif type(filters) == "function" then
        local height, width = vim.o.lines, math.floor(vim.o.columns * 5 / 8)
        local shift = vim.o.columns - width
        return vim.tbl_extend('force', {
            width = math.floor(height / row_size),
            height = math.floor(width / col_size),
            row = row,
            col = shift + col,
            filter = filters
        }, config.window.config)
    end
end

return M
