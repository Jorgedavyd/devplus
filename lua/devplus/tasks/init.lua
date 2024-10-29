local icons = require("devplus.obsidian.icons")
local logs = require("devplus.logs")
local config = _G.Config.tasks

---@class Task
---@field obsidian table
---@field inline table
---@field category number? Task category identifier
---@field priority number? Priority level (1-5)
---@field description string? Task description
---@field schedule_date integer? Scheduled date timestamp
---@field due_date integer? Due date timestamp
---@field start_date integer? Start date timestamp
---@field created integer? Creation date timestamp
---@field id string? Task identifier
---@field recursive string? Recurrence pattern
---@field opts TaskOpts Additional task options
local Task = {}
Task.__index = Task

---@class TaskOpts
---@field extmark_id number? Neovim extmark identifier
---@field checkmark_status boolean Completion status of the task
---@field path string? File path containing the task
---@field lnum number? Line number in file
---@field buffers number[][]? matrix buffers and line numbers for idx

---@param date_str? string
---@param pattern? string
---@return integer?
local function parse_date(date_str, pattern)
    if date_str and pattern then
        local year, month, day = date_str:match(pattern)
        if year and month and day then
            return os.time({ year = tonumber(year), month = tonumber(month), day = tonumber(day) })
        end
        logs.error("Invalid date format.")
    end
end

--- Creates a new task instance
---@param opts? table Initial task properties
---@return Task
function Task.new(opts)
    local self = setmetatable({}, Task)
    opts = opts or {}

    self.due_date = parse_date(opts.due_date, config.time_format)
    self.schedule_date = parse_date(opts.schedule_date, config.time_format)
    self.start_date = parse_date(opts.start_date, config.time_format) or os.time()
    self.created = parse_date(opts.created, config.time_format) or os.time()

    self.category = opts.category
    self.priority = (opts.priority and opts.priority >= 1 and opts.priority <= 5) and opts.priority or nil
    self.description = opts.description or ""
    self.id = opts.id
    self.recursive = opts.recursive

    self.opts = {
        extmark_id = opts.extmark_id,
        checkmark_status = opts.checkmark_status or false,
        path = opts.path,
        lnum = opts.lnum,
    }

    return self
end

--- Decodes the task into Obsidian Markdown format
---@param task Task
---@return string
function Task.obsidian.decoder(task)
    local parts = {}
    table.insert(parts, task.opts.checkmark_status and "- [x]" or "- [ ]")
    if task.priority then
        table.insert(parts, icons.priority[task.priority] or "")
    end
    if task.description then
        table.insert(parts, task.description)
    end
    if task.due_date then
        table.insert(parts, ("%s (%s)"):format(icons.due_date or "", os.date("%Y-%m-%d", task.due_date)))
    end
    if task.schedule_date then
        table.insert(parts, string.format("%s (%s)", icons.schedule_date or "", os.date("%Y-%m-%d", task.schedule_date)))
    end
    if task.start_date then
        table.insert(parts, string.format("%s (%s)", icons.start_date or "", os.date("%Y-%m-%d", task.start_date)))
    end
    if task.created then
        table.insert(parts, string.format("%s (%s)", icons.created or "", os.date("%Y-%m-%d", task.created)))
    end
    if task.id then
        table.insert(parts, string.format("%s (%s)", icons.id or "", task.id))
    end
    if task.recursive then
        table.insert(parts, string.format("%s (%s)", icons.recursive or "", task.recursive))
    end
    return table.concat(parts, " ")
end

--- Toggles the checkmark status of a task
---@param task Task
function Task.toggle_checkmark(task)
    task.opts.checkmark_status = not task.opts.checkmark_status
    return task
end

--- Parses a task from a string
---@param str string Task string to parse
---@return Task
function Task.obsidian.encoder(str)
    local opts = {}
    local due_date, schedule_date, priority, created, start_date, id, recursive = str:match(icons.grep_string)

    opts.due_date = due_date
    opts.schedule_date = schedule_date
    opts.start_date = start_date
    opts.created = created
    opts.id = id
    opts.recursive = recursive

    if priority then
        for i, prio_symbol in ipairs(icons.priority) do
            if priority == prio_symbol then
                opts.priority = i
                break
            end
        end
    end

    return Task.new(opts)
end

--- Retrieves format string and keys for inline encoding
---@return string?, table?
function Task.get_format()
    local grep_string = _G.Config.tasks.inline_format
    if not grep_string:find("category") then
        logs.error("Invalid format: TODOs require a category/namespace")
        return nil
    end

    local format_keys = {}
    for key, _ in pairs(Task) do
        local start_pos, end_pos = grep_string:find(key)
        if start_pos and end_pos then
            table.insert(format_keys, {
                key = key,
                start_pos = start_pos,
                end_pos = end_pos,
                text = grep_string:sub(start_pos, end_pos)
            })
            grep_string = grep_string:gsub(key, "(.)")
        end
    end
    table.sort(format_keys, function(a, b) return a.start_pos < b.start_pos end)
    return grep_string, format_keys
end

--- Encodes a task inline based on format
---@param str string
---@return Task?
function Task.inline.encoder(str)
    local fmt, format_keys = Task.get_format()
    if fmt and format_keys then
        local groups = {str:match(fmt)}
        if #groups == #format_keys then
            local opts = {}
            for idx, key_info in ipairs(format_keys) do
                opts[key_info.key] = groups[idx]
            end
            return Task.new(opts)
        else
            logs.error("Pattern mismatch in inline encoder.")
        end
    end
end

return Task
