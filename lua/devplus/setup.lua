local database = require("devplus.database")
local ptr = require("devplus.tasks.ptr")
local checkmark = require("devplus.tasks.checkmark")
local themes = require("telescope.themes")
local sorter = require("devplus.tasks.sorter")
local icons = require("devplus.obsidian.icons")

---@class Setup
---@field default table
---@field forward function
local M = {}

---@class Config
---@field obsidian table
---@field tasks table
---@field tracker table
---@field telescope table?

---@type Config
local default_config = {
    obsidian = {
        vault = nil,
        project = "projects",
    },
    tasks = {
        categories = {
            TODO = {
                icon = "📝",
            },
            --[[DATA = {
                icon = "⛁",     -- Database icon (simple)
                -- Alternative options:
                -- icon = "🗄️",  -- File cabinet
                -- icon = "⛃",   -- Another database variant
                -- icon = "🖪",   -- Technical database icon
            },
            TRAIN = {
                icon = "🚂",
            }]]--
        },
        time_format = "%y%m%d",
        ptr_virtual_text = "->",
        undone_virtual_text = "",
        done_virtual_text = "",
        inline_format = "{category, due_date, priority} description"
    },
    tracker = {
        hook = 1800,
    },
}

local function create_dependent_config(base_config)
    return {
        telescope = {
            find_tasks = {
                dyn_title = function(_, task)
                    return base_config.tasks.categories[task.category].icon .. ":" .. task.priority
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
                display = function(task)
                    return base_config.tasks.categories[task.category].icon
                        .. icons.priority[task.priority]
                        .. (":%s"):format(task.description)
                end,
                attach_mappings = function(_, map)
                    map('n', '>', ptr.toggle)
                    map('n', '+', checkmark.toggle)
                end,
                sorter = function(task)
                    return sorter.default(task)
                end
            },
            snippets = {
                theme_opts = themes.get_dropdown({
                    layout_config = {
                        vertical = {
                            prompt_position = 'top',
                        },
                    },
                    sorting_strategy = "ascending",
                    border = true,
                })
            }
        },
        tasks = vim.tbl_extend("force", base_config.tasks, {
            matrix = {
                filters = {
                    {
                        function(task)
                            return (task.priority >= 4) -- mid, high, highest
                                and (task.due_date < os.time() + 3600*24*3) -- 3 days
                        end,
                        function(task)
                            return (task.priority >= 4)
                                and (task.due_date > os.time() + 3600*24*3)
                        end,
                    },
                    {
                        function(task)
                            return (task.priority <= 4)
                                and (task.due_date < os.time() + 3600*24*3)
                        end,
                        function(task)
                            return (task.priority <= 4)
                                and (task.due_date > os.time() + 3600*24*3)
                        end,
                    }
                },
                config = {
                    style = 'minimal',
                    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
                },
                display = function(task)
                    return base_config.tasks.categories[task.category].icon
                        .. icons.priority[task.priority]
                        .. (":%s"):format(task.description)
                end,
                buffer_mappings = function(_, map)
                    map('n', '>', ptr.toggle)
                    map('n', '+', checkmark.toggle)
                end,
            }
        })
    }
end

---@type Config?
M.config = {}

M.default = default_config

function M.forward(opts)
    local base_config = vim.tbl_deep_extend('force', default_config, opts or {})
    local dependent_config = create_dependent_config(base_config)
    M.config = vim.tbl_deep_extend('force', base_config, dependent_config, opts or {})
    database.init()
end

_G.Config = M.config

return M
