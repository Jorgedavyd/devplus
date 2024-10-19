local db = require("devplus.database.raw").database
local log = require("devplus.logs")
---@class DatabaseFunctions
---@field create function
local M = {}

---@type table <number, string>
M.default = {}

---@param func function
---@return nil
function M.create(func)
    local meta = debug.getinfo(func)
    if db then
        db:create_function(meta.name, meta.nparams, function (ctx, ...)
            return ctx:result_number(func(...))
        end)
    end
    log.error("Database not initialized properly for feature engineering")
end

---@param functions table<number, function>
---@return nil
function M.init(functions)
    M.assert(functions)
    for _, func in ipairs(functions) do
        M.create(func)
    end
end

---@param functions table<number, function>
---@return nil
function M.assert(functions)
    for _, func in ipairs(functions) do
        if type(func) ~= 'function' then
            log.error("Not valid parameter db_functions, must be a list of functions")
        end
    end
end

return M
