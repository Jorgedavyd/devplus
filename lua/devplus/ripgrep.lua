local Task = require("devplus.tasks")
local logs = require("devplus.logs")
local meta = require("devplus.obsidian.icons")
local obsidian = require("devplus.obsidian")

local M = {}

---@private
local function get_ripgrep_cmd_obsidian()
    local cmd = {'rg', '--color=never', '--no-heading', '--line-number', '-o'}
    local pattern = meta.grep_string
    if not pattern then
        logs.warning("Pattern for ripgrep is not defined.")
        return
    end
    table.insert(cmd, pattern)

    local todo = obsidian.resolveVault()
    if not todo then
        logs.warning("Vault path could not be resolved.")
        return
    end

    table.insert(cmd, "-g")
    table.insert(cmd, todo)
    table.insert(cmd, vim.fs.dirname(todo))
    return cmd
end

local function get_regex()
    local grep_string = _G.Config.tasks.inline_format
    if not string.find(grep_string, "category") then
        logs.error("Invalid format string: TODOs require a category/namespace")
        return
    end
    local keywords = { "due_date", "schedule_date", "priority", "created", "start_date", "id", "recursive" }
    for _, key in ipairs(keywords) do
        grep_string = string.gsub(grep_string, key, "(.-)")
    end
    return grep_string
end


---@private
local function get_ripgrep_cmd_inline()
    local cmd = {'rg', '--color=never', '--no-heading', '--line-number', '-o'}
    local pattern = get_regex()
    if not pattern then
        logs.warning("Pattern for ripgrep is not defined.")
        return nil
    end
    table.insert(cmd, pattern)
    local project = obsidian.resolveProject()
    if not project then
        logs.warning("Vault path could not be resolved.")
        return nil
    end
    table.insert(cmd, project)
    return cmd
end

function M.grep(callback)
    local cmd1 = get_ripgrep_cmd_obsidian()
    local cmd2 = get_ripgrep_cmd_inline()
    if cmd1 and cmd2 then
        cmd1 = table.insert(cmd1, "&&")
        local cmd = vim.list_extend(cmd1, cmd2)
        if not cmd then
            return
        end
    else
        logs.error("Couldn\'t create the grep operation")
    end

    local tasks = {}

    local on_stdout = function(_, data)
        if data then
            for _, line in ipairs(data) do
                if line ~= '' then
                    local file, lnum, text = line:match('([^:]+):(%d+):(.+)')
                    if file and lnum and text then
                        table.insert(tasks, {
                            text = text:gsub('^%s+', ''),
                            filename = file,
                            lnum = tonumber(lnum)
                        })
                    end
                end
            end
        end
    end

    local on_exit = function(_, _)
        local formatted_tasks = vim.tbl_map(function(x)
            local task = Task.new(x.text)
            task.opts = {
                path = x.filename,
                lnum = x.lnum,
                checkmark_status = false,
            }
            return task
        end, tasks)

        if _G.cache and _G.cache.append then
            _G.cache.append(formatted_tasks)
        else
            logs.warning("Cache append function is not available.")
        end

        callback(formatted_tasks)
    end

    vim.fn.jobstart(cmd, {
        on_stdout = on_stdout,
        on_exit = on_exit,
        stdout_buffered = true
    })
end

return M
