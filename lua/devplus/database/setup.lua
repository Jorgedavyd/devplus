local sqlite3 = require('lsqlite3')
---@class RawAPI
---@field GET function
---@field POST function
local M = {}

M.database = nil

function M.init()
    local db_path = vim.fn.stdpath('data') .. '/devplus.db'
    local ok, err = pcall(function()
        M.database = sqlite3.open(db_path)
        M.database:exec[[PRAGMA foreign_keys = ON;]]
        for _, module in pairs({M.categories, M.sources, M.priority, M.language,
                                M.projects, M.breaks, M.files, M.buffer_records,
                                M.tasks, M.editing_time, M.ptr_records}) do
            module()
        end
    end)

    if not ok then
        vim.notify("Failed to initialize database: " .. tostring(err), vim.log.levels.ERROR)
        return false
    end

    return true
end

function M.categories ()
    M.database:exec[[
            CREATE TABLE IF NOT EXISTS category_id (
                id INTEGER PRIMARY KEY,
                name TEXT,
                icon TEXT
            );
        ]]
end

function M.tasks ()
    M.database:exec[[
        CREATE TABLE IF NOT EXISTS task_id (
            id INTEGER PRIMARY KEY,
            category INTEGER,
            file TEXT,
            due_date DATETIME,
            priority INTEGER,
            finish_date DATETIME,
            source INTEGER,
            FOREIGN KEY(category) REFERENCES category_id(id) ON DELETE CASCADE,
            FOREIGN KEY(file) REFERENCES file_id(id) ON DELETE CASCADE,
            FOREIGN KEY(source) REFERENCES source_id(id) ON DELETE CASCADE,
            FOREIGN KEY(priority) REFERENCES priority_id(id) ON DELETE CASCADE
        );
    ]]
end

function M.sources()
    M.database:exec[[
        CREATE TABLE IF NOT EXISTS source_id (
            id INTEGER PRIMARY KEY,
            name TEXT,
    );
    ]]
end

M.priority = {
    init = function ()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS priority_id (
                id INTEGER PRIMARY KEY,
                name TEXT,
                icon TEXT
        );
        ]]
    end
}

function M.files()
    M.database:exec[[
        CREATE TABLE IF NOT EXISTS file_id (
            id INTEGER PRIMARY KEY,
            project INTEGER,
            name TEXT,
            language INTEGER,
            FOREIGN KEY(project) REFERENCES project_id(id) ON DELETE CASCADE,
            FOREIGN KEY(language) REFERENCES language_id(id) ON DELETE CASCADE
        );
        ]]
end

function M.language()
    M.database:exec[[
        CREATE TABLE IS NOT EXISTS language (
            id INTEGER PRIMARY KEY,
            extension TEXT,
            name TEXT
        );
        ]]
end

function M.projects()
    M.database:exec[[
        CREATE TABLE IF NOT EXISTS project_id (
            id INTEGER PRIMARY KEY,
            name TEXT
    );
    ]]
end

function M.ptr_records()
    M.database:exec[[
        CREATE TABLE IF NOT EXISTS ptr_record (
            id INTEGER PRIMARY KEY,
            task INTEGER,
            begin DATETIME,
            end DATETIME,
            FOREIGN KEY(task) REFERENCES task_id(id) ON DELETE CASCADE
        );
    ]]
end

function M.buffer_records()
    M.database:exec[[
        CREATE TABLE IF NOT EXISTS buffer_record (
            id INTEGER PRIMARY KEY,
            file INTEGER,
            begin DATETIME,
            lines_added INTEGER,
            end DATETIME,
            editing_time INTERVAL,
            FOREIGN KEY(file) REFERENCES file_id(id) ON DELETE CASCADE
        );
    ]]
end

function M.editing_time()
    M.database:exec[[
        CREATE TABLE IF NOT EXISTS editing_time (
            id INTEGER PRIMARY KEY,
            record INTEGER,
            begin DATETIME,
            end DATETIME,
            editing_time INTERVAL,
            FOREIGN KEY(record) REFERENCES buffer_record(id) ON DELETE CASCADE
        );
    ]]
end

function M.breaks()
    M.database:exec[[
        CREATE TABLE IF NOT EXISTS break_record (
            id INTEGER PRIMARY KEY,
            begin DATETIME,
            end DATETIME
        );
    ]]
end

return M
