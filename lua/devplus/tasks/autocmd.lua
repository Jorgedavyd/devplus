local api = vim.api

local M = {}

M.buffer_id = api.nvim_create_augroup("devplus-tasks", {clear = false})

api.nvim_create_autocmd(
    {"VimEnter"},
    {
        group = M.buffer_id,
        callback = function ()
            require("devplus.matrix").manager.init()
            require("devplus.ripgrep").grep()
        end,
    }
)

api.nvim_create_autocmd(
    {"BufWrite"},
    {
        group = M.buffer_id,
        callback = function ()
            require("devplus.tasks.scanner").current_update()
        end,
    }
)

return M
