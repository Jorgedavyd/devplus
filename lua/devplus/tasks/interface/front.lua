local config = require("setup").config.prettier
local api = vim.api

---@class Prettier

local M = {}

---@type table<string, string>
M.config = config

---@type number | nil
M.namespace = nil

function M.init(buffer)
    M.assert(buffer)
    M.namespace = api.nvim_create_namespace("Prettier")
end

---@private
---@param buffer number
---@return nil
function M.assert(buffer)
end

return M
