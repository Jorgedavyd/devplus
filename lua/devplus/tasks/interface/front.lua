local config = require("devplus.setup").tasks.categories
local api = vim.api

---@class Prettier

local M = {}

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
