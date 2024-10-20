local api = vim.api

local M = {}

M.buffer_id = api.nvim_create_augroup("devplus-tasks", {clear = false})

---This one will look through all files to find the TODOs,
---it will be non-blocking or lazy to avoid overhead at startup.
api.nvim_create_autocmd(
    {"VimEnter"},
    {
        group = M.buffer_id,
        callback = function ()
            ---create the buffers and the windows
            ---Look through all the files in the project
            ---create the tasks
            ---add the tasks to the cache
        end,
    }
)

---This one will check if the current buffer has new tasks.
api.nvim_create_autocmd(
    {"BufWrite"},
    {
        group = M.buffer_id,
        callback = function ()
            require("devplus.tasks.scanner").current_update()
        end,
    }
)

---This one will check if the current buffer has new tasks.
api.nvim_create_autocmd(
    {"VimLeave"},
    {
        group = M.buffer_id,
        callback = function ()
            --- Delete all the tasks that've been done
            --- Deactivates all the tasks that've been running
            --- ingest the tasks status to SQL.
        end,
    }
)

return M
