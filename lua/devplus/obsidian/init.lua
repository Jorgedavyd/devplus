local log = require("devplus.logs")
local config = require("devplus.setup").config.obsidian
local parser = require("devplus.obsidian.parser")
local uv = vim.loop

local M = {}


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

---@param task Task
---@return nil
function M.send (task)
    local project_path = resolveProject()
    if not project_path then
        logs.error("Couldn't find project base directory, project must be a git repository")
    end
    local target = vim.fn.resolve(config.vault .. "/" .. config.project .. "/" .. project_path .. "/todo.md")
    local block = parser.singleBlockParser(task)
    local file = io.open(target, 'a')
    if file then
        file:write(block)
        file:close()
    else
        log.error("Couldn't open " .. target)
    end
end

return M
