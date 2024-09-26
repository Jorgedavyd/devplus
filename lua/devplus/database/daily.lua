local fe = require("tracker.feature_engineering")
local raw = require("raw")

---@class DailyAPI
local M = {}

function M.init()
    raw.init()
end

function M.linesAdded()
    raw.database:exec[[
            CREATE TABLE IS NOT EXISTS lines_added (
                id INTEGER PRIMARY KEY,
                time INTEGER
            );
        ]]
end

function M.linesRemoved()
    raw.database:exec[[
            CREATE TABLE IS NOT EXISTS lines_removed (
                id INTEGER PRIMARY KEY,
                time INTEGER
            );
        ]]
end

function M.cumTimeLanguage()
    raw.database.exec[[
            CREATE TABLE IS NOT EXISTS time_language (
                id INTEGER PRIMARY KEY,
                language INTEGER,
                time INTEGER,
                FOREIGN KEY(language) REFERENCES language_id(id) ON DELETE CASCADE
            );
        ]]
end

return M
