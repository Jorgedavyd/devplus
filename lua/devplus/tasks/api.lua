local buffer = require("devplus.tasks.interface.buffer")
local prettier = require("devplus.tasks.interface.front")

local M = {}

---@return nil
function M.tasks.toggle_interface()
end

---@return nil
function M.tasks.access_task()
end

---@return nil
function M.tasks.toggle_pointer()
end

---@return nil
function M.tasks.toggle_checkmark()
    local current_line = vim.fn.line('.') - 1
    local extmarks = vim.api.nvim_buf_get_extmarks(buffer.buf, prettier.namespace, {current_line, 0}, {current_line, -1}, {})
    local uncompleted_mark = "☐"
    local completed_mark = "☑"

    if #extmarks > 0 then
        -- If an extmark exists, toggle its state
        local existing_mark = vim.api.nvim_buf_get_extmark_by_id(buffer.buf, prettier.namespace, extmarks[1][1], {details = true})
        local current_text = existing_mark.virt_text[1][1]

        if current_text == uncompleted_mark then
            -- Task is uncompleted, mark as completed
            vim.api.nvim_buf_set_extmark(buffer.buf, prettier.namespace, current_line, 0, {
                id = extmarks[1][1],
                virt_text = {{completed_mark, "Comment"}, {"", "Comment"}},
                virt_text_pos = "overlay",
                hl_mode = "combine",
                virt_text_win_col = 0,
            })

            -- Apply strikethrough to the entire line
            local line_text = vim.api.nvim_buf_get_lines(buffer.buf, current_line, current_line + 1, false)[1]
            vim.api.nvim_buf_add_highlight(buffer.buf, prettier.namespace, "Comment", current_line, 0, -1)
            vim.api.nvim_buf_set_lines(buffer.buf, current_line, current_line + 1, false, {string.rep("─", #line_text)})
        else
            -- Task is completed, mark as uncompleted
            vim.api.nvim_buf_set_extmark(buffer.buf, prettier.namespace, current_line, 0, {
                id = extmarks[1][1],
                virt_text = {{uncompleted_mark, "Comment"}},
                virt_text_pos = "overlay",
                virt_text_win_col = 0,
            })

            -- Remove strikethrough
            vim.api.nvim_buf_clear_namespace(buffer.buf, prettier.namespace, current_line, current_line + 1)
            local original_text = vim.b.original_lines and vim.b.original_lines[current_line + 1]
            if original_text then
                vim.api.nvim_buf_set_lines(buffer.buf, current_line, current_line + 1, false, {original_text})
            end
        end
    else
        -- If no extmark exists, add one (uncompleted state)
        vim.api.nvim_buf_set_extmark(buffer.buf, prettier.namespace, current_line, 0, {
            virt_text = {{uncompleted_mark, "Comment"}},
            virt_text_pos = "overlay",
            virt_text_win_col = 0,
        })

        -- Store original line text
        local line_text = vim.api.nvim_buf_get_lines(buffer.buf, current_line, current_line + 1, false)[1]
        if not vim.b.original_lines then
            vim.b.original_lines = {}
        end
        vim.b.original_lines[current_line + 1] = line_text
    end
end

---@return nil
function M.tasks.reset_cache()
end

return M
