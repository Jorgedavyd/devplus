local api = require('devplus.tracker.api')
local database = require("devplus.database")
local ptr = require("devplus.tasks.interface.ptr")
---@class Setup
---@field default table
---@field forward function
local M = {}

M.default = {
    keymaps = function ()
    end,
    ---@param buf number
    ---@return nil
    buffer_keymaps = function (buf)
        api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
            noremap = true,
            callback = function()
                ptr.jump_to_task(buf)
            end,
            desc = "Jump to task file"
        })
    end,
    obsidian = {
        vault = "",
        project = "projects/",
    },
    tasks= {
        windows = {
            filters = {
                {
                    function (task)
                        return (task.priority == 'high') and (task.due_date < os.time() + 3600*24*3) -- 3 days
                    end,
                    function (task)
                        return (task.priority == 'high') and (task.due_date > os.time() + 3600*24*3)
                    end,
                },
                {
                    function (task)
                        return (task.priority == 'low' or task.priority == 'medium') and (task.due_date < os.time() + 3600*24*3)
                    end,
                    function (task)
                        return (task.priority == 'low' or task.priority == 'medium') and (task.due_date > os.time() + 3600*24*3)
                    end,
                }
            },
            config = {
                style = 'minimal',
                border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            }
        },
        categories = {
            TODO = " ",
            DATA = "",
            TRAIN = ""
        },
        time_format = "%y%m%d",
        ptr_virtual_text = "->"
    },
    tracker = {
        interval = 1800, --- Database ingestion every one hour
        sql_functions = {
        },
        visualization = {
            api.tracker.visualization.bar(),
        }
    },
    llm = {
        type = "", --- Look at supported models (if there's not one of yours, you can implement it yourself)
        token = "" --- include your API token, be careful!!
    }
}


function M.forward(opts)
    ---@type table<string, function|string|table>
    M.config = vim.tbl_deep_extend('force', opts, M.default)
    database.forward(opts.tracker)
end

return M

