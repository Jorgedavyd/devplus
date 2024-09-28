local template = require("devplus.obsidian.template")

---@class ObsidianParser
---@field task function
---@field singleBlockParser function
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
        if group then
            line = string.replace(line, "{{" .. group .. "}}", task[template.todo_default[group]])
        end
        table.insert(block, line)
    end
    return block
end

return M
