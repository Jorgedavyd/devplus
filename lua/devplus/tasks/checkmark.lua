local api = vim.api
local config = require("devplus.setup").config.cache
local cache = require("devplus.tasks.cache")

---@class Checkmark
---@field toggle function
local M = {}

M.namespace = api.nvim_create_namespace("devplus-checkmark")
--- checkmark.toggle: This function formats the
--- task on toggle to indicate that it is mark.
--- The idea is that if this is activated on
--- Vim Exit, it should delete the TODO on all
--- platforms.

---@return nil
function M.toggle()
    local bufnr = vim.api.nvim_get_current_buf()
    local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local task = cache[current_line].opts
    if task then
        if task.checkmark_status then
            M.unmark(bufnr, current_line)
        else
            M.mark(bufnr, current_line)
        end
    end
end

---Gives mark virtual formatting
---@private
---@param bufnr number
---@param current_line number
---@return nil
function M.mark(bufnr, current_line)
    cache[current_line].opts.checkmark_status = true
    vim.api.nvim_buf_set_extmark(bufnr, M.namespace, current_line, 0, {
        virt_text = {{config.icon, "Comment"}},
        virt_text_pos = 'overlay',
        virt_text_win_col = 0,
    })
end

---Gives mark virtual formatting
---@private
---@param bufnr number
---@param current_line number
---@return nil
function M.unmark(bufnr, current_line)
    cache[current_line].opts.checkmark_status = false
    vim.api.nvim_buf_set_extmark(bufnr, M.namespace, current_line, 0, {
        virt_text = {{config.icon, "Comment"}},
        virt_text_pos = 'overlay',
        virt_text_win_col = 0,
    })
end

return M
