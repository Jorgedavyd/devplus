local parser = require("parser")

local M = {}

---@return table|nil
function M.get_changed_linetasks()
    local bufnr = vim.api.nvim_get_current_buf()
    local changes = vim.fn.getchangelist(bufnr)[1]
    if #changes == 0 then
        return
    end
    table.sort(changes, function (a, b)
        return a.lnum < b.lnum
    end)

    local changed_tasks = {}
    for _, change in pairs(changes) do
        local line = vim.api.nvim_buf_get_lines(bufnr, change.lnum - 1, change.lnum, false)[1]
        local task = parser.get_task(line)
        if task then
            table.insert(changed_tasks, task)
        end
    end
    if #changed_tasks ~= 0 then
        return changed_tasks
    end
end

return M
