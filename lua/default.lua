local tcp = require("tcp")
local tasks = require("tasks")

local M = {}

---@return nil
function M.setup()
    tcp.keymap.setup()
    tasks.keymap.setup()
end

return M

