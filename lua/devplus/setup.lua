local api = require('devplus.tracker.api')
local database = require("devplus.database")
---@class Setup
---@field windows table<string|number, function>
---@field buffer table<number, ...>
---@field prettier table<string, string>
---@field keymaps function
local M = {}

M.default = {
    keymaps = function ()
    end,
    obsidian = {
        vault = "",
        project = "",
    },
    tasks= {
        windows = {
            filters = {
                {
                    function (task)
                        return (task.priority == 'high') and (task.due_date < os.time(os.date("*t")) + )
                    end,
                    function (task)
                        return (task.priority == 'high') and (task.due_date > os.date() + os.time(day = 5))
                    end,
                },
                {
                    function (task)
                        return (task.priority == 'low' or task.priority == 'medium') and (task.due_date < os.date() + os.time(day = 5))
                    end,
                    function (task)
                        return (task.priority == 'low' or task.priority == 'medium') and (task.due_date > os.date() + os.time(day = 5))
                    end,
                }
            },
            config = {
                relative = 'editor',
                style = 'minimal',
                border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            }
        },
        categories = {
            TODO = "" ---shoutout to folke for these icons
        },
        time_format = "%y%m%d",
        ptr_virtual_text= "->"
    },
    tracker = {
        sql_functions = {

        },
        visualization = {
            api.tracker.visualization.bar(x = [[]], y = [[]])
        }
    },
    llm = {
        type = "", --- Look at supported models (if there's not one of yours, you can implement it yourself)
        token = "" --- include your token, be careful!!
    }
}

---@type table<string, function|string|table>
M.config = nil

function M.forward(opts)
    M.config = vim.tbl_deep_extend('force', opts, M.default)
    database.forward(opts.tracker)
    tasks.forward(opts.tasks)
    tracker.forward(opts.tracker)
end

return M

