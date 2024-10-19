local config = require("devplus.setup").config
local filters = require("devplus.setup").config.filters
local logs = require("devplus.logs")
local utils = require("devplus.tasks.utils")

---@class WindowConfig
---@field style string
---@field border string
---@field relative string

---@class WindowDimensions
---@field width number
---@field height number
---@field row number
---@field col number

---@class Windows
---@field config WindowConfig
---@field windows table<number, number>
---@field configs table
---@field setWindows function
local M = {}

M.windows = {}

---@private
---@param filters table
---@return table
function M.getWindowsConfig(filters, row_size, row, col_size, col)
    local opts = {}
    if type(filters) == 'table' then
        assert(type(col_size) == 'nil', "Invalid argument: col_size should be nil for nested configuration")
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
        }, config.window.config or {})
    end
    return opts
end

M.configs = M.getWindowsConfig(filters)

---@private
---@param opts table
---@return nil
function M.filter_assert(opts)
    for idx, ops in ipairs(opts) do
        if type(ops) == 'table' then
            M.filter_assert(ops)
        elseif type(ops) == 'function' then
            if not utils.isFilterFunction(ops) then
                logs.error(string.format(
                    "Invalid function at index %d in windows opts, expected function(task) -> boolean",
                    idx
                ))
            end
        end
    end
end

---@private
---@param opts table<string, string>
---@return nil
function M.config_assert(opts)
    local valid_keys = { style = true, border = true, relative = true }
    for name, _ in pairs(opts) do
        if not valid_keys[name] then
            logs.error(string.format(
                "Invalid argument '%s' for config, expected: relative, style, or border",
                name
            ))
        end
    end
end

---@private
---@param opts table
---@return nil
function M.matrix_assert(opts)
    if type(opts[1]) == "table" then
        for i = 1, #opts - 1 do
            if (#opts[i] ~= #opts[i + 1]) then
                logs.error("Config must be a grid of NxM with no void spaces.")
            end
        end
    end
end

---@return nil
function M.assert()
    M.filter_assert(config.windows.filters)
    M.config_assert(config.windows.config)
    M.matrix_assert(config.windows.filters)
end

return M
