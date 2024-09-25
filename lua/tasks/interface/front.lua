local config = require("default")
local api = vim.api

---@class Prettier
---@field signs table<string, string>
local M = {}

---@type table<string, string>
M.config = config.prettier

---@type number | nil
M.namespace = nil

function M.init(buffer)
    M.namespace = api.nvim_create_namespace("Prettier")

end

M.motes = {

}

return M
