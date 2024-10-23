local icons = require("devplus.obsidian.icons")
---@class Task
---@field obsidian table
---@field inline table
---@field category number|nil Task category identifier
---@field priority number|nil Priority level (1-5)
---@field description string|nil Task description
---@field schedule_date osdate|nil Scheduled date string
---@field due_date osdate|nil Due date timestamp
---@field start_date osdate|nil Start date string
---@field created osdate|nil Creation date string
---@field id string|nil Task identifier
---@field recursive string|nil Recurrence pattern
---@field opts TaskOpts Additional task options
local Task = {}
Task.__index = Task

---@class TaskOpts
---@field extmark_id number|nil Neovim extmark identifier
---@field checkmark_status boolean Completion status of the task
---@field path string|nil File path containing the task
---@field lnum number|nil Line number in file

-- Create a new task instance
---@param opts? table Initial task properties
---@return Task
function Task.new(opts)
    local self = setmetatable({}, Task)
    opts = opts or {}
    self.due_date = opts.due_date
    self.category = opts.category
    if opts.priority then
        if opts.priority >=1 and opts.priority <=5 then
            self.priority = opts.priority
        end
    end
    self.description = opts.description
    self.schedule_date = opts.schedule_date
    self.start_date = opts.start_date or os.date("%Y-%m-%d")
    self.created = opts.created or os.date("%Y-%m-%d")
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
        table.insert(parts, string.format("%s (%s)", icons.schedule_date, task.schedule_date))
    end
    if task.start_date then
        table.insert(parts, string.format("%s (%s)", icons.start_date, task.start_date))
    end
    if task.created then
        table.insert(parts, string.format("%s (%s)", icons.created, task.created))
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

function Task.inline.encoder(str)
end

return Task
