local parser = require("parser")
local config = require("config")

local M = {}

---@param task table [[string]: string]
---@return nil
function M.send(task)
    local obsTask = parser.task(task)
    local path = M.getPath()
end

function M.getPathc()
    return vim.fn.resolve(config.vault .. config.project_rel_path .. "todo.md");
end

function M.retrieve(task)

end

return M
