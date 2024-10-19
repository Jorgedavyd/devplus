---@class DatabaseResult
---@field success boolean
---@field affected_rows number|nil
---@field error string|nil

local raw = require('devplus.database.raw')

local M = {}


---Execute an SQL statement with parameters
---@param sql string The SQL query to execute
---@param params table The parameters to bind
---@return DatabaseResult
local function exec_sql(sql, params)
    local success, result

    success, result = pcall(function()
        local stmt = assert(raw.database:prepare(sql))
        local res = stmt:bind_values(table.unpack(params)):step()
        stmt:reset()
        return res
    end)

    if not success then
        return {
            success = false,
            error = "SQL execution failed: " .. tostring(result)
        }
    end

    return {
        success = true,
        affected_rows = raw.database:changes()
    }
end

---Create a parameterized values string for ingestion
---@param params table Array of field names
---@return string value_string The constructed values string
local function createValueString(params)
    if #params == 0 then
        error("No fields provided for value string creation")
    end
    local out = {}
    for _, _ in ipairs(params) do
        table.insert(out, "?")
    end
    local placeholders = table.concat(out, ",")
    return string.format("(%s),", placeholders)
end

---Perform bulk insert operation into specified table
---@param table_id string The target table name
---@param fields table Array of field names
---@param data table Array of arrays containing values to insert
---@return DatabaseResult
function M.bulk_ingest(table_id, fields, data)
    -- Input validation
    if type(table_id) ~= "string" or table_id == "" then
        return { success = false, error = "Invalid table_id" }
    end

    if type(fields) ~= "table" or #fields == 0 then
        return { success = false, error = "Invalid or empty fields array" }
    end

    if type(data) ~= "table" or #data == 0 then
        return { success = false, error = "Invalid or empty data array" }
    end

    -- Sanitize table_id to prevent SQL injection
    if not table_id:match("^[%w_]+$") then
        return { success = false, error = "Invalid table name format" }
    end

    -- Construct query
    local value_string = createValueString(fields)
    local field_list = "(" .. table.concat(fields, ',') .. ")"
    local values_part = string.rep(value_string, #data):sub(1, -2)

    local query = string.format(
        "INSERT INTO %s %s VALUES %s",
        table_id,
        field_list,
        values_part
    )

    local flat_data = {}
    for _, row in ipairs(data) do
        if #row ~= #fields then
            return {
                success = false,
                error = string.format(
                    "Row data length (%d) doesn't match fields length (%d)",
                    #row,
                    #fields
                )
            }
        end
        for _, value in ipairs(row) do
            table.insert(flat_data, value)
        end
    end

    return exec_sql(query, flat_data)
end

M.tasks = {
    ---Send single task to the queue
    ---@param task Task The task to queue
    ---@return DatabaseResult
    single_task = function(task)
        if not task.category then
            return { success = false, error = "Task must have a category" }
        elseif not task.due_date then
            return { success = false, error = "Task must have a due date" }
        elseif not task.priority then
            return { success = false, error = "Task must have a priority" }
        end
        --- Setup the rest
    end,

    ---Record task metadata
    ---@param task Task The task to record metadata for
    ---@return DatabaseResult
    metadata = function(task)
    end,
}

---@class TaskTracker
M.tracker = {
}

return M
