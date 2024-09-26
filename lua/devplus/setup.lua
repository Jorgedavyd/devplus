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
            {
                function (task)
                    return (task.priority == 'high') and (task.due_date < os.date() + os.date(days = 5))
                end,
                function (task)
                    return (task.priority == 'high') and (task.due_date > os.date() + os.date(days = 5))
                end,
            },
            {
                function (task)
                    return (task.priority == 'low' or task.priority == 'medium') and (task.due_date < os.date() + os.date(days = 5))
                end,
                function (task)
                    return (task.priority == 'low' or task.priority == 'medium') and (task.due_date > os.date() + os.date(days = 5))
                end,
            }
        },
        categories = {
            TRAIN = "", ---shoutout to folke for these icons
            DATA = ""
        },
    },
    tracker = {
        db_functions = {
        },
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
end

return M

