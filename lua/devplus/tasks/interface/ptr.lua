local api = vim.api

local M = {}
M.namespace = api.nvim_create_namespace("devplus-pointer")

M.flag = false

---@param buffers table
---@param task_index number
---@param buf_index number
function M.toggle_ptr(buffers, task_index, buf_index)
    if not M.flag then
        for _, buf in ipairs(buffers) do
            local extmarks = api.nvim_buf_get_extmarks(buf, M.namespace, 0, -1, { details = true })
            if buf == buf_index then
                for i, extmark in ipairs(extmarks) do
                    local id, line, col, _ = unpack(extmark)
                    if i == task_index then
                        api.nvim_buf_set_extmark(buf, M.namespace, line, col, {
                            id = id,
                            hl_group = "Normal",
                            hl_eol = true,
                            virt_text = {{">", "Statement"}},
                            virt_text_pos = "overlay",
                            virt_text_win_col = 0
                        })
                    else
                        api.nvim_buf_set_extmark(buf, M.namespace, line, col, {
                            id = id,
                            hl_group = "Comment",
                            hl_eol = true,
                            virt_text = {{" ", "Comment"}, {" // Task Hidden", "Comment"}},
                            virt_text_pos = "overlay",
                            virt_text_win_col = 0
                        })
                    end
                end
            else
                for _, extmark in ipairs(extmarks) do
                    local id, line, col, _ = unpack(extmark)
                    api.nvim_buf_set_extmark(buf, M.namespace, line, col, {
                        id = id,
                        hl_group = "Comment",
                        hl_eol = true,
                        virt_text = {{" ", "Comment"}, {" // Task Hidden", "Comment"}},
                        virt_text_pos = "overlay",
                        virt_text_win_col = 0
                    })
                end
            end
        end
    else
        for _, buf in ipairs(buffers) do
            local extmarks = api.nvim_buf_get_extmarks(buf, M.namespace, 0, -1, { details = true })
            for _, extmark in ipairs(extmarks) do
                local id, line, col, _ = unpack(extmark)
                api.nvim_buf_set_extmark(buf, M.namespace, line, col, {
                    id = id,
                    hl_group = "Normal",
                    hl_eol = true,
                    virt_text = {{" ", "Normal"}},
                    virt_text_pos = "overlay",
                    virt_text_win_col = 0
                })
            end
        end
    end
    M.flag = not M.flag
end

return M
