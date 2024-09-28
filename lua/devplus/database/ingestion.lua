local M = {}

local raw = require('devplus.database.raw')

local function exec_sql(sql, params)
    local stmt = assert(raw.database:prepare(sql))
    local result = stmt:bind_values(table.unpack(params)):step()
    stmt:reset()
    return result
end

local function get_single_value(sql, params)
    local stmt = assert(raw.database:prepare(sql))
    local result = stmt:bind_values(table.unpack(params)):step()
    local value = result[1]
    stmt:reset()
    return value
end

local function createValueString(params)
    local value_string = "("
    for _ = 1, #params do
        value_string = value_string .. "?,"
    end
    value_string = string.sub(value_string, 1, -2) .. "),"
    return value_string
end

function M.bulk_insert(table_id, fields, data)
    local value_string = createValueString(fields)
    local params = "(" .. table.concat(fields, ',') .. ")"
    local query = string.format("INSERT INTO %s %s VALUES %s", table_id, params, string.rep(value_string, #data):sub(1, -2))

    local flat_data = {}
    for _, row in ipairs(data) do
        for _, value in ipairs(row) do
            table.insert(flat_data, value)
        end
    end

    return exec_sql(query, flat_data)
end

function M.get_or_create_category_id(name, icon)
    local sql = [[
        INSERT OR IGNORE INTO category_id (name, icon) VALUES (?, ?);
        SELECT id FROM category_id WHERE name = ?;
    ]]
    exec_sql(sql, {name, icon})
    return get_single_value("SELECT id FROM category_id WHERE name = ?", {name})
end

function M.get_or_create_source_id(name)
    local sql = [[
        INSERT OR IGNORE INTO source_id (name) VALUES (?);
        SELECT id FROM source_id WHERE name = ?;
    ]]
    exec_sql(sql, {name})
    return get_single_value("SELECT id FROM source_id WHERE name = ?", {name})
end

function M.get_or_create_priority_id(name, icon)
    local sql = [[
        INSERT OR IGNORE INTO priority_id (name, icon) VALUES (?, ?);
        SELECT id FROM priority_id WHERE name = ?;
    ]]
    exec_sql(sql, {name, icon})
    return get_single_value("SELECT id FROM priority_id WHERE name = ?", {name})
end

function M.get_or_create_language_id(extension, name)
    local sql = [[
        INSERT OR IGNORE INTO language_id (extension, name) VALUES (?, ?);
        SELECT id FROM language_id WHERE extension = ?;
    ]]
    exec_sql(sql, {extension, name})
    return get_single_value("SELECT id FROM language_id WHERE extension = ?", {extension})
end

function M.get_or_create_project_id(name)
    local sql = [[
        INSERT OR IGNORE INTO project_id (name) VALUES (?);
        SELECT id FROM project_id WHERE name = ?;
    ]]
    exec_sql(sql, {name})
    return get_single_value("SELECT id FROM project_id WHERE name = ?", {name})
end

function M.get_or_create_file_id(project_name, file_name, language_extension)
    local project_id = M.get_or_create_project_id(project_name)
    local language_id = M.get_or_create_language_id(language_extension, nil)
    local sql = [[
        INSERT OR IGNORE INTO file_id (project, name, language) VALUES (?, ?, ?);
        SELECT id FROM file_id WHERE project = ? AND name = ?;
    ]]
    exec_sql(sql, {project_id, file_name, language_id, project_id, file_name})
    return get_single_value("SELECT id FROM file_id WHERE project = ? AND name = ?", {project_id, file_name})
end

function M.bulk_upsert_tasks(tasks)
    local prepared_tasks = {}
    for _, task in ipairs(tasks) do
        local category_id = M.get_or_create_category_id(task.category_name, task.category_icon)
        local file_id = M.get_or_create_file_id(task.project_name, task.file_name, task.language_extension)
        local priority_id = M.get_or_create_priority_id(task.priority_name, task.priority_icon)
        local source_id = M.get_or_create_source_id(task.source_name)

        table.insert(prepared_tasks, {
            category_id, file_id, task.due_date, task.description,
            priority_id, task.ai and 1 or 0, task.finish_date, source_id
        })
    end

    return M.bulk_insert("task_id",
        {"category", "file", "due_date", "description", "priority", "ai", "finish_date", "source"},
        prepared_tasks)
end

function M.bulk_insert_ptr_records(ptr_records)
    local prepared_records = {}
    for _, record in ipairs(ptr_records) do
        local task_id = get_single_value("SELECT id FROM task_id WHERE description = ?", {record.task_description})
        if not task_id then
            error("Task not found: " .. record.task_description)
        end
        table.insert(prepared_records, {task_id, record.begin, record.end_time})
    end

    return M.bulk_insert("ptr_record", {"task", "begin", "end"}, prepared_records)
end

function M.bulk_insert_buffer_records(buffer_records)
    local prepared_records = {}
    for _, record in ipairs(buffer_records) do
        local file_id = M.get_or_create_file_id(record.project_name, record.file_name, record.language_extension)
        table.insert(prepared_records, {file_id, record.begin, record.lines_added, record.end_time, record.editing_time})
    end

    return M.bulk_insert("buffer_record",
        {"file", "begin", "lines_added", "end", "editing_time"},
        prepared_records)
end

function M.bulk_insert_editing_times(editing_times)
    local prepared_records = {}
    for _, record in ipairs(editing_times) do
        local file_id = M.get_or_create_file_id(record.project_name, record.file_name, record.language_extension)
        local buffer_record_id = get_single_value("SELECT id FROM buffer_record WHERE file = ? ORDER BY begin DESC LIMIT 1", {file_id})
        if not buffer_record_id then
            error("No buffer record found for file: " .. record.file_name)
        end
        table.insert(prepared_records, {buffer_record_id, record.begin, record.end_time, record.editing_time})
    end

    return M.bulk_insert("editing_time",
        {"record", "begin", "end", "editing_time"},
        prepared_records)
end

function M.bulk_insert_breaks(breaks)
    return M.bulk_insert("break_record", {"begin", "end"}, breaks)
end

return M
