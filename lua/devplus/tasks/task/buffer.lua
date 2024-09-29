local categories = require("devplus.setup").config.tasks.categories
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
                table.insert(tasks, {
                    task = encoder.inline(string.sub(line, start, -1)),
                    line = start_line + i
                })
            end
        end
    end
    return tasks
end

function M.get_new()
    local bufnr = api.nvim_get_current_buf()
    local changes = vim.fn.getchangelist(bufnr)[1]
    if #changes > 0 then
        local last_change = changes[#changes]
        local tasks = M.scan(bufnr, last_change[1] - 1, last_change[1] - 1)
        return tasks
    end
end

return M
