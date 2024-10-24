local icons = require("devplus.obsidian.icons")
local logs = require("devplus.logs")
local config = _G.Config.tasks

---@class Task
---@field obsidian table
---@field inline table
---@field category number? Task category identifier
---@field priority number? Priority level (1-5)
---@field description string? Task description
---@field schedule_date integer? Scheduled date string
---@field due_date integer? Due date timestamp
---@field start_date integer? Start date string
---@field created integer? Creation date string
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
local function strftime(date_str, pattern)
    if date_str and pattern then
        local year, month, day = date_str:match(pattern)
        if year and month and day then
            return os.time({
                year = tonumber(year),
                month = tonumber(month),
                day = tonumber(day),
            })
        end
        logs.error("Not valid date_str")
    end
end

-- Create a new task instance
---@param opts? table Initial task properties
---@return Task
function Task.new(opts)
    local self = setmetatable({}, Task)
    opts = opts or {}
    self.due_date = strftime(opts.due_date, config.time_format)
    self.category = opts.category
    if opts.priority then
        if opts.priority >=1 and opts.priority <=5 then
            self.priority = opts.priority
        end
    end
    self.description = opts.description
    self.schedule_date = strftime(opts.schedule_date, config.time_format)
    self.start_date = strftime(opts.start_date, config.time_format)
    self.created = strftime(opts.created, config.time_format)
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

---Decodes the input task into markdown obsidian task
---@param task Task
---@return string
function Task.obsidian.decoder(task)
    local parts = {}
    table.insert(parts, task.opts.checkmark_status and "- [x]" or "- [ ]")
    if task.priority then
        table.insert(parts, icons.priority[task.priority])
    end
    if task.description then
        table.insert(parts, task.description)
    end
    if task.due_date then
        table.insert(parts, ("%s (%s)"):format(icons.due_date, os.date("%Y-%m-%d", task.due_date)))
    end
    if task.schedule_date then
        table.insert(parts, string.format("%s (%s)", icons.schedule_date, os.date("%Y-%m-%d", task.schedule_date)))
    end
    if task.start_date then
        table.insert(parts, string.format("%s (%s)", icons.start_date, os.date("%Y-%m-%d", task.start_date)))
    end
    if task.created then
        table.insert(parts, string.format("%s (%s)", icons.created, os.date("%Y-%m-%d", task.created)))
    end
    if task.id then
        table.insert(parts, string.format("%s (%s)", icons.id, task.id))
    end
    if task.recursive then
        table.insert(parts, string.format("%s (%s)", icons.recursive, task.recursive))
    end
    return table.concat(parts, " ")
end

---@param task Task
function Task.toggle_checkmark(task)
    task.opts.checkmark_status = not task.opts.checkmark_status
    return task
end

-- Parse task from string
---@param str string Task string to parse
---@return Task
function Task.obsidian.encoder(str)
    local opts = {}

    local due_date, schedule_date, priority, created, start_date, id, recursive = str:match(icons.grep_string)

    if due_date then
        opts.due_date = due_date
    end
    if schedule_date then
        opts.schedule_date = schedule_date
    end
    if start_date then
        opts.start_date = start_date
    end
    if created then
        opts.created = created
    end
    if id then
        opts.id = id
    end
    if recursive then
        opts.recursive = recursive
    end

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

return Task
