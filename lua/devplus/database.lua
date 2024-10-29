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

function M.setup()
    local ok, err = pcall(function()
        local database = M.open()
        database:exec[[PRAGMA foreign_keys = ON;]]
        for _, module in pairs({M.buffer_records, M.tasks, M.ptr_records}) do
            module.setup()
        end
    end)

    if not ok then
        vim.notify("Failed to initialize database: " .. tostring(err), vim.log.levels.ERROR)
        return false
    end

    return true
end

M.tasks = {
    setup = function()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS task_id (
                task_id INTEGER PRIMARY KEY,
                project TEXT,
                file TEXT,
                language TINYTEXT,
                category TINYTEXT,
                priority TINYINT CHECK (priority BETWEEN 1 AND 5),
                due_date DATE,
                schedule_date DATE,
                start_date DATE,
                id TEXT,
                created DATE,
                recursive TEXT,
                finished DATE,
            );
        ]]
    end,
    ingest = function()
        M.ingest("task_id",
            {"project", "file", "language", "category", "priority", "due_date", "schedule_date", "start_date", "id", "created", "recursive", "finished"},
            M.tasks.queue.data)
        M.tasks.queue.data = {}
    end,
    queue = {
        data = {},
        append = function(opts)
            table.insert(M.tasks.queue.data, {opts.project,opts.file,opts.language,opts.category,opts.priority,opts.due_date,opts.schedule_date,opts.start_date,opts.id,opts.created,opts.recursive,opts.finished})
        end
    }
}

M.ptr_records = {
    setup = function()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS ptr_record (
                id INTEGER PRIMARY KEY,
                task INTEGER,
                init_date DATETIME,
                time INTEGER,
                FOREIGN KEY(task) REFERENCES task_id(id) ON DELETE CASCADE
            );
        ]]
    end,
    ingest = function()
        M.ingest("ptr_record", {"task", "init_date", "time"}, M.ptr_records.queue.data)
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
    setup = function()
        M.database:exec[[
            CREATE TABLE IF NOT EXISTS buffer_record (
                init_time DATETIME,
                total_time INTEGER,
                editing_time INTEGER,
                lines_added INTEGER,
                lines_deleted INTEGER,
                file TEXT,
                ptr INTEGER,
                FOREIGN KEY(ptr) REFERENCES ptr_records(id) ON DELETE CASCADE
            );
        ]]
    end,
    ingest = function()
        M.ingest(
            "buffer_record",
            {"init_time", "total_time", "editing_time", "lines_added", "lines_deleted", "file", "ptr"},
            M.buffer_records.queue.data
        )
        M.buffer_records.queue.data = {}
    end,
    queue = {
        data = {},
        append = function(opts)
            table.insert(M.buffer_records.queue.data, {opts.init_time,opts.total_time,opts.editing_time,opts.lines_added,opts.lines_deleted,opts.file,opts.ptr})
        end
    }
}

_G.db = M
