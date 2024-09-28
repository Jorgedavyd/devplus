local api = vim.api
local buffer = require("devplus.tasks.interface.buffer")
local task_tracking = require("devplus.tasks.buffer")
local config = require("devplus.setup").config

local M = {}

M.id = api.nvim_create_augroup("devplus-task-buffer", {clear = false})

api.nvim_create_autocmd(
    {"VimEnter"},
    {
        group = M.id,
        desc = "Initialize devplus task buffer.",
        callback = function ()
            buffer.init()
        end
    })

api.nvim_create_autocmd(
    {"TextChanged"},
    {
        group = M.id,
        desc = "Update buffer on task creation.",
        callback = function (ev)
            end
        end
    }
)

function M.ingest_default()
    --- This function ingest the default data from the category section
end

