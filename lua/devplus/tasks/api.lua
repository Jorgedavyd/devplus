local interface = require("devplus.tasks.interface")
local ptr = require("devplus.tasks.interface.ptr")
local api = vim.api

local M = {}

---@return nil
function M.tasks.toggle_interface()
    interface.toggle_interface()
end

---@return nil
function M.tasks.access_task()

end

---@return nil
function M.tasks.toggle_pointer()
    local task_index = api.nvim_win_get_cursor(0)[1] - 1
    local buf = api.nvim_get_current_buf()
    ptr.toggle_ptr(interface.buffers, task_index, buf)
end

---@return nil
function M.tasks.toggle_checkmark()
end

return M
