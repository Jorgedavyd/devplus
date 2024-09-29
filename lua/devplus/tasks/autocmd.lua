local interface = require("devplus.tasks.interface")
local task_tracking = require("devplus.tasks.buffer")
local encoder = require("devplus.tasks.task.encoder")
local task = require("devplus.tasks.task")
local api = vim.api

local M = {}

M.id = api.nvim_create_augroup("devplus-task-buffer", {clear = false})

api.nvim_create_autocmd(
    {"TextChanged"},
    {
        group = M.id,
        desc = "Devplus: Update buffer on task creation.",
        callback = function ()
            local tasks = task_tracking.get_new()
            local temp = {}

            for _, task_ in ipairs(tasks) do
                table.insert(temp, encoder.inline(task_))
            end

            for idx, i in ipairs(temp) do
                for _, j in ipairs(task.cache) do
                    if i == j then
                        table.remove(temp, idx)
                    end
                end
            end
            interface.update_buffer(temp)
        end
    }
)
