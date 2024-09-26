local sqlite3 = require('lsqlite3')
---@class RawAPI
---@field GET function
---@field POST function
local M = {}

M.database = sqlite3.open(vim.fn.stdpath('data') .. '/devplus.db')

---@private
---@return table<string, function>

M.categories = {
    init = function ()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS category_id (
                id INTEGER PRIMARY KEY,
                name TEXT,
                icon TEXT
            );
        ]]
    end,
}

M.tasks = {
    init = function ()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS task_id (
                id INTEGER PRIMARY KEY,
                category INTEGER,
                file TEXT,
                due_date DATETIME,
                description TEXT,
                priority INTEGER,
                status BIT,
                finish_date DATETIME,
                FOREIGN KEY(category) REFERENCES category_id(id) ON DELETE CASCADE,
                FOREIGN KEY(file) REFERENCES file_id(id) ON DELETE CASCADE,
                FOREIGN KEY(priority) REFERENCES priority_id(id) ON DELETE CASCADE
            );
        ]]
    end
}

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

M.files = {
    init = function ()
        M.database:exec[[
        CREATE TABLE IF NOT EXISTS file_id (
            id INTEGER PRIMARY KEY,
            project INTEGER,
            name TEXT,
            FOREIGN KEY(project) REFERENCES project_id(id) ON DELETE CASCADE
        );
        ]]
    end
}

M.projects = {
    init = function ()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS project_id (
                id INTEGER PRIMARY KEY,
                name TEXT
        );
        ]]
    end
}

M.ptr_records = {
    init = function ()
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
}

M.buffer_records = {
    init = function ()
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
}

M.editing_time = {
    init = function ()
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
}


M.breaks = {
    init = function ()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS break_record (
                id INTEGER PRIMARY KEY,
                begin DATETIME,
                end DATETIME
            );
        ]]
    end
}

return M
