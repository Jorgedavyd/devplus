local config = _G.Config.telescope or {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local sorters = require("telescope.sorters")

---@class TelescopeDevplus
---@field bufnr number
---@field toggle fun(picker: any):nil
local M = {}

---@type number
M.bufnr = vim.api.nvim_create_buf(false, true)

---@private
local get_previewer = function()
    return previewers.new_buffer_previewer({
        dyn_title = config.dyn_title,
        get_buffer_by_name = function(_, _)
            return M.bufnr
        end,
        define_preview = function(_, task, _)
            previewers.buffer_previewer_maker(task.filepath, M.bufnr, {
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
            results = vim.tbl_filter(function (x) return not x.opts.checkmark_status end, _G.cache.history),
            entry_maker = function(task)
                return {
                    value = task,
                    display = config.display(task),
                    ordinal = config.sorter(task)
                }
            end
        }),
        previewer = get_previewer(),
        sorter = sorters.get_generic_fuzzy_sorter(),
        attach_mappings = config.attach_mappings
    }

    local theme_opts = config.theme_opts
    return vim.tbl_deep_extend('force', theme_opts, default_opts)
end

function M.picker()
    return pickers.new({}, get_opts())
end

return M
