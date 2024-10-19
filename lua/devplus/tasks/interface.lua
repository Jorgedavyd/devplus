local previewers = require("telescope.previewers")
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local themes = require('telescope.themes')
local utils = require("devplus.tasks.utils")
local decoder = require("devplus.tasks.decoder")
local config = require("devplus.setup").config
local log = require("devplus.logs")
local cache = require("depvlus.tasks.cache")

---@alias Filter fun(task: Task): boolean
---@alias Opts {[string]: number}

---@class Interface
---@field buffers Buffers
---@field manager BufferManager
---@field show fun(): nil
local M = {}

---@private
---@class Buffers
---@field filters {[string]: Filter}
---@field bufnrs number[]
---@field opts Opts
M.buffers = {}

---@private
---@class HelperFunctions
local help = {
    ---@param tasks Task[]
    ---@return function[]
    get_write_tasks = function (tasks)
        local output = {}
        for idx, filter in ipairs(M.buffers.filters) do
            vim.tbl_extend(vim.tbl_map(function (task)
                return function ()
                    local buf_string = decoder.buffer(task)
                    vim.api.nvim_buf_set_lines(M.buffers.bufnrs[idx], -1, -1, false, buf_string)
                end
            end, vim.tbl_filter(tasks, filter)), output)
        end
        return output
    end,
}

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
            config.buffer_keymaps(buf)
            M.buffers.filters[idx] = filters[idx]
            M.buffers.bufnrs[idx] = buf
            M.buffers.opts[idx] = vim.tbl_deep_extend() -- Setup the window thing
        end
    end,
    ---BufferManager.update: Updates the task buffers
    ---@param tasks? Task[]
    update = function (tasks)
        if tasks then
            local task_functions = help.get_write_tasks(tasks)
            local success, _ = pcall(vim.tbl_map(function(x) x() end, task_functions))
            if not success then
                log.error("Couldn't write tasks")
            end
        end
    end
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
            for idx, buf in ipairs(M.buffers.bufnrs) do
                vim.api.nvim_open_win(buf, false, M.buffers.opts[idx])
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

M.previewer = previewers.new_buffer_previewer({
    title = "Task Preview",
    define_preview = function(self, entry)
        local task = entry.value
        if task.file and task.line then
            local lines = vim.fn.readfile(task.file)
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            local ft = vim.filetype.match({ filename = task.file })
            if ft then
                vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', ft)
            end
            vim.api.nvim_win_set_cursor(self.state.winid, { task.line, task.col or 0 })
            vim.api.nvim_buf_add_highlight(self.state.bufnr, -1, 'TelescopePreviewLine', task.line - 1, 0, -1)
        end
    end
})

function M.create_task_picker()
    local tasks = cache.history
    local picker_opts = themes.get_dropdown({
        layout_config = {
            height = 0.8,
            preview_height = 0.6,
        },
        layout_strategy = "vertical",
        sorting_strategy = "ascending",
        border = true,
        preview_title = "Task Preview",
    })
    pickers.new(picker_opts, {
        prompt_title = "Tasks",
        finder = finders.new_table({
            results = tasks,
            entry_maker = function(task)
                return {
                    value = task,
                    display = string.format("[%s] %s - %s", task.priority, task.id, task.description),
                    ordinal = task.description,
                }
            end,
        }),
        sorter = conf.generic_sorter(picker_opts),
        previewer = M.previewer,
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection then
                    local task = selection.value
                    vim.cmd(string.format('edit +%d %s', task.line, task.file))
                end
            end)
            return true
        end,
    }):find()
end

return M
