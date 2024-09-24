local parser = require("parser")
local config = require("config")

local M = {}

---@param task table <string,string>
---@return nil
function M.POST(task)
    local stringed_task = parser.task(task)
    local path = M.getPath()
end

function M.GET(task)

end

---@private
---@return string
function M.getPath()
    return vim.fn.resolve(config.vault .. config.project .. "todo.md");
end

return M
