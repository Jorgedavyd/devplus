local config = require("devplus.tasks.windows").configs
local buffers = require("devplus.tasks.buffers").buffers
local api = vim.api
local M = {}

function M.toggle_interface()
    local bufnr = api.nvim_get_current_buf()
    local found_buf = false

    -- Check if current buffer is already in the buffer list
    for _, buf in ipairs(M.buffers) do
        if buf == bufnr then
            found_buf = true
            break
        end
    end

    -- Get the config once, asynchronously
    vim.defer_fn(function()
        assert(#buffers == #config, "Not valid config")

        -- If the buffer is in the list, open the windows
        if found_buf then
            -- Open the windows asynchronously
            for idx, _ in ipairs(M.buffers) do
                vim.defer_fn(function()
                    api.nvim_open_win(M.buffers[idx], false, config[idx])
                end, 10)  -- short delay to make it non-blocking
            end
        else
            -- Close the windows asynchronously
            for idx, _ in ipairs(M.buffers) do
                vim.defer_fn(function()
                    api.nvim_win_close(api.nvim_get_current_win(), false)
                end, 10)  -- short delay to make it non-blocking
            end
        end
    end, 0)  -- deferring the whole block to make the initial call non-blocking
end

---@return nil
function M.toggle_checkmark()
end

---@return nil
function M.toggle_ptr()
end

return M
