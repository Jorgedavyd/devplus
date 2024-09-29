local categories = require("devplus.setup").config.tasks.categories
local buffer = require("devplus.tasks.interface.buffer")
local encoder = require("devplus.tasks.task.encoder")
local api = vim.api
local M = {}

M.namespace = api.nvim_create_namespace("devplus-scanner")

M.history = {}

function M.scan(buf, start_line, end_line)
    buf = buf or api.nvim_get_current_buf()
    local lines = api.nvim_buf_get_lines(buf, start_line, end_line, false)
    api.nvim_buf_clear_namespace(buf, M.namespace, 0, -1)
    local tasks = {}
    for i, line in ipairs(lines) do
        for category, _ in pairs(categories) do
            local start, _ = line:find(category)
            if start then
                api.nvim_buf_set_extmark(buf, M.namespace, i - 1, start - 1, {
                    virt_text = {{category}},
                    virt_text_pos = 'right-align'
                })
                table.insert(tasks, string.sub(line, start, -1))
            end
        end
    end
    return tasks
end

function M.treat(raw)
    local tasks = {}
    for _, task in ipairs(raw) do
        table.insert(tasks, encoder.inline(task))
    end
    return tasks
end

function M.get_new()
    local bufnr = api.nvim_get_current_buf()
    local changes = vim.fn.getchangelist(bufnr)[1]
    if #changes > 0 then
        local last_change = changes[#changes]
        local raw_tasks = M.scan(buffer.buf, last_change[1] - 1, last_change[1] - 1)
        local tasks = M.treat(raw_tasks)
        vim.list_extend('force', M.history, tasks) -- cuidado
        return tasks
    end
end

return M
