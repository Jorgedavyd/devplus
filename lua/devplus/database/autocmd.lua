local api = vim.api
local database = require("devplus.database.init")
local functions = require("devplus.database.functions")
local db_functions = require("devplus.tracker.setup").config.tracker.db_functions
local default_functions = require("devplus.tracker.feature_engineering")
local M = {}

M.id = api.nvim_create_augroup("devplus-database", {clear = false})

api.nvim_create_autocmd(
    {"VimEnter"},
    {
        group = M.id,
        desc = "Initialize database if not initialized",
        callback = function ()
            database.init()
            functions.init(vim.tbl_extend('force', default_functions, db_functions))
            M.ingest_default()
        end
    })

api.nvim_create_autocmd(
    {"VimEnter"},
    {
        group = M.id,
        desc = "Initialize database if not initialized",
        callback = function ()
        end
    })


