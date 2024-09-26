---@class Status
---@field update function
---@field self boolean
local M = {}

---@type boolean
M.self = false

---@return nil | Status
function M.update()
    local cache = require("cache")
    if not temp then
        return
    end
    return M
end

M.interface = {
    init = function ()
    end,
    deinit = function ()
    end,
    window = function ()
    end,
    buffer = {
    }
}

---@return nil
function M.

end

--- set autocmd

return M
