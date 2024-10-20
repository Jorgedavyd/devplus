local categories = require("devplus.setup").config.tasks.categories
local themes = require("telescope.themes")
local cache = require("devplus.tasks.cache")
local decoder = require("devplus.tasks.decoder")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local sorters = require("telescope.sorters")
local checkmark = require("devplus.tasks.checkmark")
local ptr = require("devplus.tasks.ptr")

local cats = vim.tbl_keys(categories)

---@class TelescopeTasks
---@field bufnr number
---@field pickers TelescopePickers
---@field toggle fun():nil
local M = {}

---@type number
M.bufnr = vim.api.nvim_create_buf(false, true)

---@private
local get_previewer = function()
    return previewers.new_buffer_previewer({
        ---@param _ nil
        ---@param task Task
        ---@return string
        dyn_title = function(_, task)
            return cats[task.category].icon .. ":" .. task.priority
        end,
        get_buffer_by_name = function(_, _)
            return M.bufnr
        end,
        define_preview = function(_, task, _)
            previewers.buffer_previewer_maker(task.value.filepath, M.bufnr, {
                use_ft_detect = true,
                bufname = "devplus-task-preview",
            })
        end,
    })
end

---@private
local get_opts = function ()
    local default_opts = {
        prompt_title = 'Tasks',
        finder = finders.new_table({
            results = cache.history,
            entry_maker = function(task)
                return {
                    value = task,
                    display = decoder.telescope(task),
                    ordinal = sorters.default(task),
                }
            end
        }),
        previewer = get_previewer(),
        sorter = sorters.get_generic_fuzzy_sorter(),
        attach_mappings = function (_, map)
            map('n', '>', ptr.toggle())
            map('n', '+', checkmark.toggle())
        end
    }

    local theme_opts = themes.get_dropdown({
        layout_config = {
            vertical = {
                prompt_position = 'top',
            },
        },
        sorting_strategy = "ascending",
        border = true,
    })
    return vim.tbl_deep_extend('force', theme_opts, default_opts)
end

M.picker = pickers.new({}, get_opts())

function M.toggle()
    M.picker:find()
end

return M
