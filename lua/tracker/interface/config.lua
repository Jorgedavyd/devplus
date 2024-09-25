local buffer = require("buffer")
local win = require("windows")
local prettier = require("front")

---@class Config
---@field buffer table<string, string|boolean|number>
---@field windows Config
---@field prettier table<string, string>
local M = {
    buffer = buffer.config,
    windows = win.config,
    prettier = prettier.config
}

return M
