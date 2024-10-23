local config = _G.Config or {}
local utils = require("devplus.tasks.utils")
local logs = require("devplus.logs")
local log = require("devplus.logs")

---@class Matrix
---@field buffers Buffers
---@field manager BufferManager
---@field show fun(): nil
local M = {}

---@alias Filter fun(task: Task): boolean
---@alias Opts {[string]: number}

---@class WindowConfig
---@field style string
---@field border string
---@field relative string

---@class WindowDimensions
---@field width number
---@field height number
---@field row number
---@field col number

---@private
---@param filters Filter[]|Filter
---@param row_size? number
---@param row? number
---@param col_size? number
---@param col? number
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
        local height, width = vim.o.lines, vim.o.columns
        return vim.tbl_extend('force', {
            width = math.floor(height / row_size),
            height = math.floor(width / col_size),
            row = row,
            col = col,
        }, config.tasks.matrix.config or {})
    end
    return opts
end

function M.filter_assert(opts)
    assert(#opts == 2 or #opts == 4, "Not valid number of rows.")
    if #opts == 4 then
        for _, opt in ipairs(opts) do
            assert(type(opt) == 'function', ("Not valid filter function, found: {%s}"):format(type(opt)))
        end
    end
    for _, opt in ipairs(opts) do
       assert(#opt == 2, "Not valid number of columns.")
    end
end

---@private
---@param opts {[string]: string|string[]}
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

---@return nil
function M.assert()
    M.filter_assert(config.tasks.matrix.filters)
    M.config_assert(config.tasks.matrix.config)
end

M.assert()
M.config = M.getWindowsConfig(config.tasks.matrix.filters)

---@private
---@class Buffers
---@field filters {[string]: Filter}
---@field bufnrs number[]
---@field opts Opts
M.buffers = {}

---@class BufferManager
---@field checkUpdates function This is for the autocmd each time a buffer is written.
---@field init function On init autocmd to setup (lazy) the buffers.
M.manager = {
    ---buffers.init: Initializes all buffers related to tasks
    ---@param filters Filter[]
    init = function (filters)
        for idx, _ in pairs(filters) do
            utils.isFilterFunction(filters[idx])
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_option(buf, 'modifiable', false)
            vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
            config.tasks.buffer_keymaps(buf)
            M.buffers.filters[idx] = filters[idx]
            M.buffers.bufnrs[idx] = buf
            M.buffers.opts[idx] = M.config[idx]
        end
    end,
}

function M.toggle()
    local current_buf = vim.api.nvim_get_current_buf()
    local is_interface_open = false

    for _, buf in ipairs(M.buffers.bufnrs) do
        if buf == current_buf then
            is_interface_open = true
            break
        end
    end

    vim.defer_fn(function()
        if not is_interface_open then
            for idx, filter in ipairs(M.buffers.filters) do
                vim.api.nvim_buf_set_lines(M.buffers.bufnrs[idx], 0, -1, false, {})
                local keys = vim.tbl_keys(_G.cache.history)
                local tasks = vim.tbl_filter(function (x)
                    return filter(_G.cache.history[x])
                end, keys)
                keys = vim.tbl_keys(tasks)
                for i=1,keys do
                    table.insert(_G.cache.history[tasks[i]].opts.buffers, {bufnr = M.buffers.bufnrs[idx], lnum = i})
                end
                local buf_string = vim.tbl_map(function (x)
                    return config.tasks.matrix.display(_G.cache.history[x])
                end, tasks)
                vim.api.nvim_buf_set_lines(M.buffers.bufnrs[idx], -1, -1, false, buf_string)
                vim.api.nvim_open_win(M.buffers.bufnrs[idx], false, M.buffers.opts[idx])
            end
        else
            local wins = vim.api.nvim_list_wins()
            for _, win in ipairs(wins) do
                local win_buf = vim.api.nvim_win_get_buf(win)
                for _, buf in ipairs(M.buffers) do
                    if win_buf == buf then
                        vim.api.nvim_win_close(win, false)
                        break
                    end
                end
            end
        end
    end, 0)
end

function M.jump()
    local bufnr = vim.api.nvim_get_current_buf()
    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    local output = vim.tbl_filter(function(x)
        return vim.tbl_contains(x.opts.buffers, {bufnr, lnum})
    end, _G.cache.history)
    if #output == 0 then
        log.error("No matching task found for the current buffer and line.")
        return
    elseif #output > 1 then
        log.error("Multiple tasks found. This shouldn't happen.")
        return
    end
    output = output[1]
    local filepath = output.opts.path
    local line_number = output.opts.lnum
    if vim.fn.filereadable(filepath) == 0 then
        log.error("The file does not exist: " .. filepath)
        return
    end
    vim.cmd("edit " .. filepath)
    vim.api.nvim_win_set_cursor(0, {line_number + 1, 0})
end

return M
