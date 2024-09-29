local config = require("devplus.setup").config.tasks
local windows = require("devplus.tasks.interface.windows")
local buffer = require("devplus.tasks.interface.buffer")
local decoder = require("devplus.tasks.task.decoder")
local ptr = require("devplus.tasks.interface.ptr")

local api = vim.api

---@class Interface
---@field toggle_interface function
---@field update_buffer function
local M = {}

---@private
---@param iterables table
---@return table
local function chain_from_iterable(iterables)
    local result = {}
    for _, iterable in ipairs(iterables) do
        for _, value in ipairs(iterable) do
            table.insert(result, value)
        end
    end
    return result
end

windows.assert()
M.window_config = windows.getWindowsConfig(config.windows.filters)
if type(M.window_config[0]) == "table" then
    M.window_config = chain_from_iterable(M.window_config)
end

M.buffers = {}
for _, opt in pairs(M.window_config) do
    local buf = buffer.init(opt.filter)
    table.insert(M.buffers, buf)
end

M.windows = {}

function M.toggle_interface()
    for idx, buf in ipairs(M.buffers) do
        if M.windows[idx] and api.nvim_win_is_valid(M.windows[idx]) then
            api.nvim_win_close(M.windows[idx], true)
            M.windows[idx] = nil
        else
            local win = api.nvim_open_win(buf, true, M.window_config[idx])
            api.nvim_win_set_buf(win, buf)
            M.windows[idx] = win
        end
    end
end

---@param tasks table<number, Task>
function M.update_buffer(tasks)
    for _, opts in ipairs(M.window_config) do
        for _, task in pairs(tasks) do
            if opts.filter(task) then
                buffer.append(opts.buf, decoder.buffer(task))
            end
        end
    end
end

return M
