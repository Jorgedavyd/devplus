local setup = require("devplus.setup")
local async = require("plenary.async").async
local await = require("plenary.async").await
local filter = require("devplus.tasks.interface.filter")
local logs = require("devplus.logs")
local api = vim.api

---@alias Config table<number, Filter> | table<number, table<number, Filter>>
---@alias WinMatrix table<number, string|number|Filter> | table<number, table<number, number|string|Filter>>
---@class Windows
---@field config Config
---@field setWindows function
local M = {}

---@private
---@param config Config | Filter
---@return nil
function M.filter_assert(config)
    for idx, ops in ipairs(config) do
        if type(ops) == 'table' then
            M.filter_assert(ops)
        elseif type(ops) == 'function' then
            if !filter.isFilterFunction(config) then
                logs.error("Not valid function at function" .. idx .. " in windows opts, expected a function(task) -> boolean")
            end
        end
    end
end

---@private
---@param config table<string, string>
---@return nil
function M.config_assert(config)
    for name, _ in pairs(config) do
        local flag
        for _, value in {'relative', 'style', 'border'} do
            if name == value then
                flag = 1
            end
        end
        if !flag then
            logs.error("Not valid argument %s for config, expected relative, style, border")
        end
    end
end

---@param config table<string, Config | table<string, string>>
---@return nil
function M.assert(config)
    M.filter_assert(config.filters)
    M.config_assert(config.config)
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
        return vim.tbl_deep_extend('force', {
            width = math.floor(height / row_size),
            height = math.floor(width / col_size),
            row = row,
            col = shift + col,
            filter = filters
        }, setup.windows.config)
    end
end

M.windows = {}

function M.close()
    local tasks = {}
    for _, win in pairs(M.windows) do
        table.insert(tasks, async(function()
            await(vim.schedule_wrap(function ()
                api.nvim_win_close(win)
            end))
        end)
    )
    end
    async.util.gather(tasks)
end

function M.open()
    local tasks = {}
    for _, win in pairs(M.windows) do
        table.insert(tasks, async(function()
            await(vim.schedule_wrap(function ()
                api.nvim_win_open(win)
            end))
        end)
    )
    end
    async.run(async.util.join(table.unpack(tasks)))
end


return M
