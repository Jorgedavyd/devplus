local sqlite3 = require('lsqlite3')
---@class Database
local M = {}

M.database = nil

function M.open()
    return sqlite3.open(vim.fn.stdpath('data') .. '/devplus.db')
end

---@param columns string[]
---@param opts table
function M.ingest(name, columns, opts)
    local db = M.open()
    db:exec("BEGIN TRANSACTION;")
    local stmt = db:prepare(("INSERT INTO %s (%s) VALUES (%s);"):format(
        name,
        table.concat(columns, ','),
        table.concat(vim.tbl_map(function()
            return "?"
        end, columns), ',')))
    for _, value in ipairs(opts) do
        stmt:bind_values(table.unpack(value))
        stmt:step()
        stmt:reset()
    end
    db:exec("COMMIT;")
    stmt:finalize()
    db:close()
end

function M.init()
    local ok, err = pcall(function()
        local database = M.open()
        database:exec[[PRAGMA foreign_keys = ON;]]
        for _, module in pairs({M.categories, M.sources, M.priority, M.language,
                                M.projects, M.breaks, M.files, M.buffer_records,
                                M.tasks, M.editing_time, M.ptr_records}) do
            module.init()
        end
    end)

    if not ok then
        vim.notify("Failed to initialize database: " .. tostring(err), vim.log.levels.ERROR)
        return false
    end

    return true
end

M.categories = {
    init = function()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS category_id (
                id INTEGER PRIMARY KEY,
                name TEXT,
                icon TEXT
            );
        ]]
    end,
    ingest = function()
        M.ingest("category_id", {"name", "icon"}, M.categories.queue.data)
        M.categories.queue.data = {}
    end,
    queue = {
        data = {},
        append = function(opts)
            table.insert(M.categories.queue.data, {opts.name, opts.icon})
        end
    }
}

M.tasks = {
    init = function()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS task_id (
                id INTEGER PRIMARY KEY,
                category INTEGER,
                file TEXT,
                due_date DATETIME,
                created DATETIME,
                priority INTEGER,
                finish_date DATETIME,
                source INTEGER,
                FOREIGN KEY(category) REFERENCES category_id(id) ON DELETE CASCADE,
                FOREIGN KEY(file) REFERENCES file_id(id) ON DELETE CASCADE,
                FOREIGN KEY(source) REFERENCES source_id(id) ON DELETE CASCADE,
                FOREIGN KEY(priority) REFERENCES priority_id(id) ON DELETE CASCADE
            );
        ]]
    end,
    ingest = function()
        M.ingest("task_id",
            {"category", "file", "due_date", "created", "priority", "finish_date", "source"},
            M.tasks.queue.data)
        M.tasks.queue.data = {}
    end,
    queue = {
        data = {},
        append = function(opts)
            table.insert(M.tasks.queue.data, {
                opts.category,
                opts.file,
                opts.due_date,
                opts.created,
                opts.priority,
                opts.finish_date,
                opts.source
            })
        end
    }
}

M.sources = {
    init = function()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS source_id (
                id INTEGER PRIMARY KEY,
                name TEXT
            );
        ]]
    end,
    ingest = function()
        M.ingest("source_id", {"name"}, M.sources.queue.data)
        M.sources.queue.data = {}
    end,
    queue = {
        data = {},
        append = function(opts)
            table.insert(M.sources.queue.data, {opts.name})
        end
    }
}

M.priority = {
    init = function()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS priority_id (
                id INTEGER PRIMARY KEY,
                name TEXT,
                icon TEXT
            );
        ]]
    end,
    ingest = function()
        M.ingest("priority_id", {"name", "icon"}, M.priority.queue.data)
        M.priority.queue.data = {}
    end,
    queue = {
        data = {},
        append = function(opts)
            table.insert(M.priority.queue.data, {opts.name, opts.icon})
        end
    }
}

M.files = {
    init = function()
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
    end,
    ingest = function()
        M.ingest("file_id", {"project", "name", "language"}, M.files.queue.data)
        M.files.queue.data = {}
    end,
    queue = {
        data = {},
        append = function(opts)
            table.insert(M.files.queue.data, {opts.project, opts.name, opts.language})
        end
    }
}

M.language = {
    init = function()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS language_id (
                id INTEGER PRIMARY KEY,
                extension TEXT,
                name TEXT
            );
        ]]
    end,
    ingest = function()
        M.ingest("language_id", {"extension", "name"}, M.language.queue.data)
        M.language.queue.data = {}
    end,
    queue = {
        data = {},
        append = function(opts)
            table.insert(M.language.queue.data, {opts.extension, opts.name})
        end
    }
}

M.ptr_records = {
    init = function()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS ptr_record (
                id INTEGER PRIMARY KEY,
                task INTEGER,
                begin DATETIME,
                end DATETIME,
                FOREIGN KEY(task) REFERENCES task_id(id) ON DELETE CASCADE
            );
        ]]
    end,
    ingest = function()
        M.ingest("ptr_record", {"task", "begin", "end"}, M.ptr_records.queue.data)
        M.ptr_records.queue.data = {}
    end,
    queue = {
        data = {},
        append = function(opts)
            table.insert(M.ptr_records.queue.data, {opts.task, opts.begin, opts.end_})
        end
    }
}

M.buffer_records = {
    init = function()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS buffer_record (
                id INTEGER PRIMARY KEY,
                file INTEGER,
                project INTEGER,
                begin DATETIME,
                lines_added INTEGER,
                end DATETIME,
                editing_time INTERVAL,
                FOREIGN KEY(file) REFERENCES file_id(id) ON DELETE CASCADE,
                FOREIGN KEY(project) REFERENCES projects(id) ON DELETE CASCADE
            );
        ]]
    end,
    ingest = function()
        M.ingest(
            "buffer_record",
            {"file", "project", "begin", "lines_added", "end", "editing_time"},
            M.buffer_records.queue.data
        )
        M.buffer_records.queue.data = {}
    end,
    queue = {
        data = {},
        append = function(opts)
            table.insert(M.buffer_records.queue.data, {
                opts.file,
                opts.project,
                opts.begin,
                opts.lines_added,
                opts.end_,
                opts.editing_time
            })
        end
    }
}

M.editing_time = {
    init = function()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS editing_time (
                id INTEGER PRIMARY KEY,
                record_id INTEGER,
                begin DATETIME,
                end DATETIME,
                editing_time INTERVAL,
                project_id INTEGER,
                FOREIGN KEY(record_id) REFERENCES buffer_record(id) ON DELETE CASCADE,
                FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE
            );
        ]]
    end,
    ingest = function()
        M.ingest(
            "editing_time",
            {"record_id", "begin", "end", "editing_time", "project_id"},
            M.editing_time.queue.data
        )
        M.editing_time.queue.data = {}
    end,
    queue = {
        data = {},
        append = function(opts)
            table.insert(M.editing_time.queue.data, {
                opts.record_id,
                opts.begin,
                opts.end_,
                opts.editing_time,
                opts.project_id
            })
        end
    }
}

M.breaks = {
    init = function()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS breaks (
                id INTEGER PRIMARY KEY,
                file_id INTEGER,
                date DATETIME,
                time INTEGER,
                FOREIGN KEY(file_id) REFERENCES files(id) ON DELETE CASCADE
            );
        ]]
    end,
    ingest = function()
        M.ingest("breaks", {"file_id", "date", "time"}, M.breaks.queue.data)
        M.breaks.queue.data = {}
    end,
    queue = {
        data = {},
        append = function(opts)
            table.insert(M.breaks.queue.data, {opts.file_id, opts.date, opts.time})
        end
    }
}

M.projects = {
    init = function ()
        M.database:exec[[
        CREATE TABLE IF NOT EXISTS projects (
            id INTEGER PRIMARY KEY,
            name TEXT,
        );
    ]]
    end,
    ingest = function ()
        M.ingest("projects", { "name" }, M.projects.queue.data)
        M.projects.queue.data = {}
    end,
    queue = {
        data = {},
        append = function (opts)
            table.insert(M.projects.queue.data, {opts.project})
        end
    }
}

_G.db = M
