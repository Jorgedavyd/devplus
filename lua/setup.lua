local tasks = require("tasks")
local tracker = require("tracker")
local obsidian = require("obsidian")
local database = require("database")

---@class Setup
---@field windows table<string|number, function>
---@field buffer table<number, ...>
---@field prettier table<string, string>
---@field keymaps function
local M = {}

return M

