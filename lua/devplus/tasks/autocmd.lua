local api = vim.api
local buffer = require("devplus.tasks.interface.buffer")
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

function M.ingest_default()
    --- This function ingest the default data from the category section
end

