local config = require("devplus.tasks.windows").configs
local buffers = require("devplus.tasks.buffers").buffers
local checkmark = require("devplus.tasks.checkmark")
local ptr = require("devplus.tasks.ptr")

local api = vim.api
local M = {}

function M.toggle_interface()
    local current_buf = api.nvim_get_current_buf()
    local is_interface_open = false

    for _, buf in ipairs(M.buffers) do
        if buf == current_buf then
            is_interface_open = true
            break
        end
    end

    vim.defer_fn(function()
        if not is_interface_open then
            for idx, buf in ipairs(M.buffers) do
                api.nvim_open_win(buf, idx == 1, M.config[idx])
            end
        else
            local wins = api.nvim_list_wins()
            for _, win in ipairs(wins) do
                local win_buf = api.nvim_win_get_buf(win)
                for _, buf in ipairs(M.buffers) do
                    if win_buf == buf then
                        api.nvim_win_close(win, false)
                        break
                    end
                end
            end
        end
    end, 0)
end

function M.setup()
    assert(#buffers == #config, "Buffer and configuration counts must match")
    M.buffers = buffers
    M.config = config
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
