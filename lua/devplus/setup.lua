local api = require('devplus.tracker.api')
local database = require("devplus.database")
local ptr = require("devplus.tasks.ptr")
local checkmark = require("devplus.tasks.checkmark")
local eisenhower = require("devplus.eisenhower")
local themes = require("telescope.themes")
local sorter = require("devplus.tasks.sorter")

---@class Setup
---@field default table
---@field forward function
local M = {}

---@class Config
M.default = {
    obsidian = {
        vault = nil,
        project = "projects",
    },
    telescope = {
        dyn_title = function(_, task)
            return Config.tasks.categories[task.category].icon .. ":" .. task.priority
        end,
        theme_opts = themes.get_dropdown({
            layout_config = {
                vertical = {
                    prompt_position = 'top',
                },
            },
            sorting_strategy = "ascending",
            border = true,
        }),
        display = function (task)
            return Config.tasks.categories[task.category].icon .. icons.priority[task.priority] .. (":%s"):format(task.description)
        end,
        attach_mappings = function (_, map)
            map('n', '>', ptr.toggle)
            map('n', '+', checkmark.toggle)
        end,
        sorter = function (task)
            return sorter.default(task)
        end
    },
    tasks= {
        matrix = {
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
            },
            display = function (task)
                return Config.tasks.categories[task.category].icon .. icons.priority[task.priority] .. (":%s"):format(task.description)
            end,
            buffer_mappings = function (_, map)
                map('n', '>', ptr.toggle)
                map('n', '+', checkmark.toggle)
            end,
        },
        categories = {
            TODO = {
                icon =  " ",
            },
            DATA = {
                icon = "",
            },
            TRAIN = {
                icon = "",
            }
        },
        time_format = "%y%m%d",
        ptr_virtual_text = "->",
        undone_virtual_text = "",
        done_virtual_text = "",
    },
    tracker = {
        hook = 1800, --- Database ingestion every time cache is load up to (interval)
    },
}


---@type Config
M.config = {}

function M.forward(opts)
    M.config = vim.tbl_deep_extend('force', opts, M.default)
    database.forward(opts.tracker)
end

return M
