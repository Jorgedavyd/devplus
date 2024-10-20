local interface = require("devplus.tasks.interface")
local telescope = require("devplus.tasks.telescope")
local checkmark = require("devplus.tasks.checkmark")
local ptr = require("devplus.tasks.ptr")

local M = {}

function M.toggle_eisenhower()
    interface.toggle()
end

function M.toggle_telescope()
    telescope.toggle()
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
