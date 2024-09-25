local config = require("obsidian.config")
local sqlite3 = require('lsqlite3')
local logs = require("logs")
---@class Database
---@field dump function
---@field load function
local M = {}
local db = sqlite3.open(vim.fn.stdpath('data') .. '/tracker.db')

---@param s string
---@param value string
---@return boolean
function string.endswith(s, value)
    local ending = string.sub(s, #s - #value, #s)
    return ending == value
end

function M.assert()
    if !string.endswith(config.database, 'db') then
        logs.error("Not valid database name")
    end
end


function M.init_db()
    db:exec[[
        CREATE TABLE IF NOT EXISTS daily_logs (
            id INTEGER PRIMARY KEY,
            file TEXT,
            timestamp TEXT,
            counter INTEGER,
            tasks_created INTEGER,
            lines_added INTEGER,
            lines_deleted INTEGER
        );

        CREATE TABLE IF NOT EXISTS task_metrics (
            id INTEGER PRIMARY KEY,
            daily_log_id INTEGER,
            planned INTEGER,
            completed INTEGER,
            FOREIGN KEY(daily_log_id) REFERENCES daily_logs(id)
        );

        CREATE TABLE IF NOT EXISTS time_spent (
            id INTEGER PRIMARY KEY,
            daily_log_id INTEGER,
            task TEXT,
            duration TEXT,
            FOREIGN KEY(daily_log_id) REFERENCES daily_logs(id)
        );

        CREATE TABLE IF NOT EXISTS daily_goals (
            id INTEGER PRIMARY KEY,
            daily_log_id INTEGER,
            goal INTEGER,
            achieved INTEGER,
            FOREIGN KEY(daily_log_id) REFERENCES daily_logs(id)
        );

        CREATE TABLE IF NOT EXISTS breaks (
            id INTEGER PRIMARY KEY,
            daily_log_id INTEGER,
            count INTEGER,
            total_duration TEXT,
            FOREIGN KEY(daily_log_id) REFERENCES daily_logs(id)
        );

        CREATE TABLE IF NOT EXISTS focus_periods (
            id INTEGER PRIMARY KEY,
            daily_log_id INTEGER,
            count INTEGER,
            total_duration TEXT,
            FOREIGN KEY(daily_log_id) REFERENCES daily_logs(id)
        );

        CREATE TABLE IF NOT EXISTS learning_time (
            id INTEGER PRIMARY KEY,
            daily_log_id INTEGER,
            duration TEXT,
            FOREIGN KEY(daily_log_id) REFERENCES daily_logs(id)
        );
    ]]
end

function M.log_daily_activity(file, timestamp, counter, tasks_created, lines_added, lines_deleted)
    local stmt = db:prepare[[
        INSERT INTO daily_logs (file, timestamp, counter, tasks_created, lines_added, lines_deleted)
        VALUES (?, ?, ?, ?, ?, ?)
    ]]
    stmt:bind_values(file, timestamp, counter, tasks_created, lines_added, lines_deleted)
    stmt:step()
    local daily_log_id = db:last_insert_rowid()
    stmt:finalize()
    return daily_log_id
end

-- Log task metrics
function M.log_task_metrics(daily_log_id, planned, completed)
    local stmt = db:prepare[[
        INSERT INTO task_metrics (daily_log_id, planned, completed)
        VALUES (?, ?, ?)
    ]]
    stmt:bind_values(daily_log_id, planned, completed)
    stmt:step()
    stmt:finalize()
end

-- Log time spent on tasks
function M.log_time_spent(daily_log_id, task, duration)
    local stmt = db:prepare[[
        INSERT INTO time_spent (daily_log_id, task, duration)
        VALUES (?, ?, ?)
    ]]
    stmt:bind_values(daily_log_id, task, duration)
    stmt:step()
    stmt:finalize()
end

-- Log daily goals
function M.log_daily_goals(daily_log_id, goal, achieved)
    local stmt = db:prepare[[
        INSERT INTO daily_goals (daily_log_id, goal, achieved)
        VALUES (?, ?, ?)
    ]]
    stmt:bind_values(daily_log_id, goal, achieved)
    stmt:step()
    stmt:finalize()
end

-- Log breaks
function M.log_breaks(daily_log_id, count, total_duration)
    local stmt = db:prepare[[
        INSERT INTO breaks (daily_log_id, count, total_duration)
        VALUES (?, ?, ?)
    ]]
    stmt:bind_values(daily_log_id, count, total_duration)
    stmt:step()
    stmt:finalize()
end

-- Log focus periods
function M.log_focus_periods(daily_log_id, count, total_duration)
    local stmt = db:prepare[[
        INSERT INTO focus_periods (daily_log_id, count, total_duration)
        VALUES (?, ?, ?)
    ]]
    stmt:bind_values(daily_log_id, count, total_duration)
    stmt:step()
    stmt:finalize()
end

-- Log learning time
function M.log_learning_time(daily_log_id, duration)
    local stmt = db:prepare[[
        INSERT INTO learning_time (daily_log_id, duration)
        VALUES (?, ?)
    ]]
    stmt:bind_values(daily_log_id, duration)
    stmt:step()
    stmt:finalize()
end

-- Get daily summary
function M.get_daily_summary(date)
    local summary = {}
    local stmt = db:prepare[[
        SELECT * FROM daily_logs
        WHERE date(timestamp) = date(?)
    ]]
    stmt:bind_values(date)
    for row in stmt:nrows() do
        summary.daily_log = row
    end
    stmt:finalize()

    if summary.daily_log then
        local daily_log_id = summary.daily_log.id

        -- Get task metrics
        stmt = db:prepare[[
            SELECT * FROM task_metrics
            WHERE daily_log_id = ?
        ]]
        stmt:bind_values(daily_log_id)
        summary.task_metrics = stmt:nrows()()
        stmt:finalize()

        -- Get time spent
        summary.time_spent = {}
        stmt = db:prepare[[
            SELECT * FROM time_spent
            WHERE daily_log_id = ?
        ]]
        stmt:bind_values(daily_log_id)
        for row in stmt:nrows() do
            summary.time_spent[row.task] = row.duration
        end
        stmt:finalize()

        -- Get other metrics...
        -- (similar queries for daily_goals, breaks, focus_periods, learning_time)
    end

    return summary
end

function M.calculate_task_completion_rate(date)
    local stmt = db:prepare[[
        SELECT AVG(CAST(completed AS FLOAT) / planned) as completion_rate
        FROM task_metrics
        JOIN daily_logs ON task_metrics.daily_log_id = daily_logs.id
        WHERE date(daily_logs.timestamp) = date(?)
    ]]
    stmt:bind_values(date)
    local result = stmt:nrows()()
    stmt:finalize()
    return result and result.completion_rate or 0
end

-- Feature engineering: Calculate average focus duration
function M.calculate_avg_focus_duration(date)
    local stmt = db:prepare[[
        SELECT AVG(CAST(SUBSTR(total_duration, 1, INSTR(total_duration, 'h') - 1) AS FLOAT) * 60 +
                   CAST(SUBSTR(total_duration, INSTR(total_duration, ' ') + 1, INSTR(total_duration, 'm') - INSTR(total_duration, ' ') - 1) AS FLOAT)) as avg_focus_minutes
        FROM focus_periods
        JOIN daily_logs ON focus_periods.daily_log_id = daily_logs.id
        WHERE date(daily_logs.timestamp) = date(?)
    ]]
    stmt:bind_values(date)
    local result = stmt:nrows()()
    stmt:finalize()
    return result and result.avg_focus_minutes or 0
end

return M
