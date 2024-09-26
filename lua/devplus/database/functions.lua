local db = require("raw").database
local log = require("logs")
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

