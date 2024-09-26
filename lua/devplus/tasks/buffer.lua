local M = {}

M.history = {}

function M.append(task)
    table.insert(M.history, task)
    --- add the ingestion step
end

return M
