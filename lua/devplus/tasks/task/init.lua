local categories = require("devplus.setup").config.tasks.categories
local encoder = require("devplus.tasks.task.encoder")
local grep = require("devplus.tasks.task.grep")
---@class Task
---@field category string
---@field due_date string
---@field priority string
---@field description string
local M = {}

M.cache = {}

for category, _ in pairs(categories) do
    local lines = grep.grep(category)
    for _, line in ipairs(lines) do
        table.insert(M.cache, encoder.inline(line))
    end
end

return M
