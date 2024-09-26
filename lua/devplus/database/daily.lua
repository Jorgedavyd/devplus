local fe = require("tracker.feature_engineering")
local raw = require("raw")

---@class DailyAPI
local M = {}

function M.init()
    raw.init()
end

function M.linesAdded()
    raw.database:exec[[
            CREATE TABLE IS NOT EXISTS lines_added,
            id INTEGER PRIMARY KEY,
            value INTEGER,
        ]]
end

function M.linesRemoved()
    raw.database:exec[[
            CREATE TABLE IS NOT EXISTS lines_removed,
            id INTEGER PRIMARY KEY,
            value INTEGER,
        ]]
end

function M.cumTimeLanguage()
end

return M
