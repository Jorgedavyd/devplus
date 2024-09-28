local raw = require("devplus.database.raw")
local functions  = require("devplus.database.functions")
local default_functions = require("devplus.tracker.feature_engineering").list
local M = {}

function M.forward(config)
    raw.init()
    functions.init(vim.tbl_extend('force', default_functions, config.sql_functions))
end

return M
