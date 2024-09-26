local ptr = require("ptr")
local encoder = require("encoder")
local decoder = require("decoder")
local logs = require("logs")

---@class Task
---@field ptr? PtrTask
---@field
local M = {
    file = nil,
}

M.ptr = ptr.init(M.file)

---@param str string
---@param mode string
---@return Task | nil
function M.init(str, mode)
    local var = mode:lower()
    assert(M.assert(var), "Not valid mode")
    return encoder[var](str)
end

---@param mode string
---@return boolean
function M.assert(mode)
    if !(mode == "obsidian" or mode == "inline") then
        return false
    end
    return true
end

function M.deinit()
    return M.
end

return M
