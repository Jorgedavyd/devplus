---@class Task
---@field due_date number|nil Due date timestamp
---@field category number|nil Task category identifier
---@field priority number|nil Priority level (1-5)
---@field description string|nil Task description
---@field schedule_date string|nil Scheduled date string
---@field start_date string|nil Start date string
---@field created string|nil Creation date string
---@field id string|nil Task identifier
---@field recursive string|nil Recurrence pattern
---@field filepath string|nil File path containing the task
---@field line number|nil Line number in file
---@field opts TaskOpts Additional task options
local Task = {}
Task.__index = Task

---@class TaskOpts
---@field extmark_id number|nil Neovim extmark identifier
---@field checkmark_status boolean Completion status of the task

-- Create a new task instance
---@param opts? table Initial task properties
---@return Task
function Task.new(opts)
    local self = setmetatable({}, Task)
    opts = opts or {}

    -- Initialize all fields with provided values or defaults
    self.due_date = opts.due_date
    self.category = opts.category
    self.priority = opts.priority
    self.description = opts.description
    self.schedule_date = opts.schedule_date
    self.start_date = opts.start_date
    self.created = opts.created or os.date("%Y-%m-%d")
    self.id = opts.id
    self.recursive = opts.recursive
    self.filepath = opts.filepath
    self.line = opts.line

    -- Initialize task options
    self.opts = {
        extmark_id = opts.extmark_id,
        checkmark_status = opts.checkmark_status or false
    }

    return self
end

-- Convert task to string representation
function Task:__tostring()
    local parts = {}

    -- Add checkmark status
    table.insert(parts, self.opts.checkmark_status and "[x]" or "[ ]")

    -- Add priority if set
    if self.priority then
        local priority_markers = {"⏬", "🔽", "🔼", "⏫", "🔺"}
        table.insert(parts, priority_markers[self.priority])
    end

    -- Add description
    if self.description then
        table.insert(parts, self.description)
    end

    -- Add dates and other metadata
    if self.due_date then
        table.insert(parts, string.format("📅 (%s)", os.date("%Y-%m-%d", self.due_date)))
    end

    if self.schedule_date then
        table.insert(parts, string.format("⏳ (%s)", self.schedule_date))
    end

    if self.start_date then
        table.insert(parts, string.format("🛫 (%s)", self.start_date))
    end

    if self.created then
        table.insert(parts, string.format("➕ (%s)", self.created))
    end

    if self.id then
        table.insert(parts, string.format("🆔 (%s)", self.id))
    end

    if self.recursive then
        table.insert(parts, string.format("🔁 (%s)", self.recursive))
    end

    return table.concat(parts, " ")
end

-- Toggle task completion status
function Task:toggle_status()
    self.opts.checkmark_status = not self.opts.checkmark_status
    return self
end

-- Set task priority
---@param level number Priority level (1-5)
function Task:set_priority(level)
    assert(level >= 1 and level <= 5, "Priority must be between 1 and 5")
    self.priority = level
    return self
end

-- Set task due date
---@param date_string string Date string in YYYY-MM-DD format
function Task:set_due_date(date_string)
    local year, month, day = date_string:match("(%d%d%d%d)-(%d%d)-(%d%d)")
    assert(year and month and day, "Invalid date format. Expected YYYY-MM-DD")
    self.due_date = os.time({year = year, month = month, day = day})
    return self
end

-- Parse task from string
---@param str string Task string to parse
---@return Task
function Task.parse(str)
    local opts = {}

    -- Parse checkmark status
    opts.checkmark_status = str:match("%[x%]") ~= nil

    -- Parse dates and metadata
    local patterns = {
        {"📅%s*%((.-)%)", "due_date"},
        {"⏳%s*%((.-)%)", "schedule_date"},
        {"🛫%s*%((.-)%)", "start_date"},
        {"➕%s*%((.-)%)", "created"},
        {"🆔%s*%((.-)%)", "id"},
        {"🔁%s*%((.-)%)", "recursive"}
    }

    for _, pattern in ipairs(patterns) do
        local value = str:match(pattern[1])
        if value then
            opts[pattern[2]] = value
        end
    end

    -- Parse priority
    local priority_markers = {"⏬", "🔽", "🔼", "⏫", "🔺"}
    for i, marker in ipairs(priority_markers) do
        if str:find(marker) then
            opts.priority = i
            break
        end
    end

    return Task.new(opts)
end

return Task
