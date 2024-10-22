---@class TaskMeta
---@field priority string[] Priority levels from lowest to highest
---@field created string Symbol for creation date
---@field due_date string Symbol for due date
---@field start_date string Symbol for start date
---@field schedule_date string Symbol for scheduled date
---@field id string Symbol for task ID
---@field recursive string Symbol for recursive tasks
---@field grep_string string Compiled pattern for matching all metadata types

local TaskMeta = {}

-- Priority levels from lowest to highest
TaskMeta.priority = {
    "⏬", -- Lowest
    "🔽", -- Low
    "🔼", -- High
    "⏫", -- Higher
    "🔺"  -- Highest
}

-- Metadata symbols
TaskMeta.created = "➕"        -- Creation date marker
TaskMeta.due_date = "📅"       -- Due date marker
TaskMeta.start_date = "🛫"     -- Start date marker
TaskMeta.schedule_date = "⏳"  -- Schedule date marker
TaskMeta.id = "🆔"            -- ID marker
TaskMeta.recursive = "🔁"      -- Recursive task marker

-- Compile pattern for matching all metadata types
-- Format: symbol (date|value) or just symbol for priorities
TaskMeta.grep_string = ("%s\\s*\\((.-)\\)|%s\\s*\\((.-)\\)|%s|➕\\s*\\((.-)\\)|%s\\s*\\((.-)\\)|%s\\s*\\((.-)\\)|%s\\s*\\((.-)\\)"):format(
    TaskMeta.due_date,
    TaskMeta.schedule_date,
    table.concat(TaskMeta.priority, "|"),
    TaskMeta.created,
    TaskMeta.start_date,
    TaskMeta.id,
    TaskMeta.recursive
)

return TaskMeta
