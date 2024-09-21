local M = {}

---@param file string
---@return table [[[string]: string]]
function M.retrieve(file)
    local out = {};
    for idx, task in vim.api.task() do
        out[idx] = task
    end

    return out
end

function M.api()

end

function M.task()

end

function M.send()
    ruwe
end

return M
