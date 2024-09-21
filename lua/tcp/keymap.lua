local ssh = require("tcp.ssh")
local tcp = require("tcp.tcp")
local sync = require("tcp.rsync")

local M = {}

---@param mode string
---@param toggle string
---@param action table|function
---@param opts table
---@return nil
function M.set(mode, toggle, action, opts)
    vim.keymap.set(mode, toggle, action, opts)
end

---@return nil
function M.default()
    M.set('n', '<C-s>', ssh.toggle(), {noremap = true, silence = true, desc = 'SSH Default connection'})
    M.set('n', '<C-s>h', function ()
        local request = ssh.toggle(true);
        sync.toggle(request);
    end, {noremap = true, silence = true, desc= "Connection with environment"})
end

return M
