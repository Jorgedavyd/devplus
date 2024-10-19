local interface = require("devplus.tasks.interface")
local checkmark = require("devplus.tasks.checkmark")
local ptr = require("devplus.tasks.ptr")

local M = {}

function M.toggle_interface()
    interface.toggle()
end

---@return nil
function M.toggle_checkmark()
    checkmark.toggle()
end

---@return nil
function M.toggle_ptr()
    ptr.toggle()
end

return M
