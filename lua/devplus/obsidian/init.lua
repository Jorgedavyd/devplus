local log = require("devplus.logs")
local template = require("devplus.obsidian.template")
local config = _G.Config.obsidian
local uv = vim.loop

local M = {}

---@param s string
---@param match string
---@param value ?string
function string.replace(s, match, value)
    value = value or ""
    local i, j = string.find(s, match)
    if i and j then
        return string.sub(s, 1, i - 1) .. value .. string.sub(s, j + 1)
    else
        return s
    end
end

---@param task table<string, string>
---@return table<string, string>
function M.singleBlockParser(task)
    local block = {}
    for _, line in ipairs(template.todo) do
        local group = string.match(line, "{{(.-)}}")
        if group and template.todo_default[group] then
            local task_value = task[template.todo_default[group]]
            if task_value then
                line = string.replace(line, "{{" .. group .. "}}", task_value)
            end
        end
        table.insert(block, line)
    end
    return block
end

---@return string|nil
local function resolveProject()
    local dir = uv.cwd()
    while dir do
        local git_path = dir .. "/.git"
        local stat = uv.fs_stat(git_path)
        if stat and stat.type == "directory" then
            return dir
        end
        local parent_dir = dir:match("(.*/)")
        if parent_dir == dir then
            return nil
        end
        dir = parent_dir
    end
end

function M.resolveVault()
    local project_path = resolveProject()
    if not project_path then
        log.error("Couldn't find project base directory, project must be a git repository")
        return nil
    end
    local target = vim.fn.resolve(config.vault .. "/" .. config.project .. "/" .. project_path)
    return target
end

---@param task Task
function M.append(task)
    if not task then
        log.error("Invalid task provided.")
        return
    end

    local block = M.singleBlockParser(task)
    local target = M.resolveVault()
    if not target then
        log.error("Target file could not be resolved.")
        return
    end

    local success, err = pcall(function()
        local file = io.open(target, 'a')
        if not file then
            log.error("Couldn't open " .. target)
            return
        end
        file:write(table.concat(block, "\n"))
        file:close()
    end)

    if not success then
        log.error("Error writing to file: " .. err)
    end
end

function M.setup()
    local project = M.resolveProject()
    if project then
        local block = template.main:gsub("{{PROJECT_PLACEHOLDER}}", project)
        local success, err = pcall(function()
            local directory = M.resolveVault()

            if vim.fn.isdirectory(directory) == 0 then
                vim.fn.mkdir(directory)
            end
            local main = vim.fn.resolve(directory .. '/main.md')
            local main_file = io.open(main, 'w')
            if not main_file then
                log.error("Couldn't open " .. main)
                return
            end
            main_file:write(block .. "\n")
            main_file:close()

            local todo = vim.fn.resolve(directory .. '/.todo.md')
            local todo_file = io.open(todo, 'a')
            if not todo_file then
                log.error("Couldn't open " .. todo)
                return
            end
            todo_file:write("# TODO\n")
            todo_file:close()
        end)

        if not success then
            log.error("Error writing to file: " .. err)
        end
    end
end

_G.obsidian = M

