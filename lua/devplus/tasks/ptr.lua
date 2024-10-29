local config = _G.Config.tasks
local ingest = require("devplus.database.ingestion")
local queue = require("devplus.database.queue")
local api = vim.api

---@class Ptr
---@field toggle function
local M = {}

M.namespace = api.nvim_create_namespace("devplus-pointer")

---@class PtrConfig
---@field line number|nil
---@field arrow_extmark_id number|nil
---@field bufnr number|nil
---@field clock_extmark_id number|nil
M.state = {}

--- ptr.toggle: This function should
--- deactivate any other ptr on all task
--- buffers, then activate on current extmark_id
--- adding virtual clock at the end of every task.
function M.toggle(flag)
    flag = flag or false
    local bufnr = vim.api.nvim_get_current_buf()
    local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1

    if flag then
        M.activate(bufnr, current_line)
        return
    end

    if M.state.bufnr and M.state.clock_extmark_id and M.state.arrow_extmark_id then
        if bufnr == M.state.bufnr and current_line == M.state.line then
            M.deactivate()
        else
            M.deactivate()
            M.toggle(true)
        end
    end
end

---@param bufnr number
---@param current_line number
---@return nil
function M.activate(bufnr, current_line)
    M.state.bufnr = bufnr
    M.state.line = current_line
    M.arr_virt_text(bufnr, current_line)
    M.clock_virt_text(bufnr, current_line)
end

---@param bufnr number
---@param current_line number
---@return nil
function M.arr_virt_text(bufnr, current_line)
    M.state.arrow_extmark_id = vim.api.nvim_buf_set_extmark(bufnr, M.namespace, current_line, 0, {
        virt_text = {{config.ptr_virtual_text, "Comment"}},
        virt_text_pos = 'overlay',
        virt_text_win_col = 0,
    })
end

---@param bufnr number
---@param current_line number
---@return nil
function M.clock_virt_text(bufnr, current_line)
    local function update_clock()
        if M.state.clock_extmark_id then -- Only update if the clock is active
            local time = os.date(config.time_format)
            vim.api.nvim_buf_set_extmark(bufnr, M.namespace, current_line, 0, {
                id = M.state.clock_extmark_id,
                virt_text = {{time, "Special"}},
                virt_text_pos = 'eol'
            })
            vim.defer_fn(update_clock, 1000)
        end
    end

    M.state.clock_extmark_id = vim.api.nvim_buf_set_extmark(bufnr, M.namespace, current_line, 0, {
        virt_text = {{os.date(config.time_format), "Special"}},
        virt_text_pos = 'eol'
    })
    vim.defer_fn(update_clock, 1000)
end

--- ptr.deactivate: Turns off the last pointer
--- by deleting all virtual text associated and
--- adding the task data for SQL ingestion.
---@return nil
function M.deactivate()
    if M.state.line and M.state.bufnr and M.state.clock_extmark_id and M.state.arrow_extmark_id then
        pcall(vim.api.nvim_buf_del_extmark, M.state.bufnr, M.namespace, M.state.arrow_extmark_id)
        pcall(vim.api.nvim_buf_del_extmark, M.state.bufnr, M.namespace, M.state.clock_extmark_id)
        queue.append(ingest.task_ptr_time)
        M.state = {line = nil, bufnr = nil, arrow_extmark_id = nil, clock_extmark_id = nil}
    end
end

return M
