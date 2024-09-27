local api = vim.api
---@alias Filter fun(value: string): boolean
---@class FiltUtils
---@field isFilter function
local M = {}

---@param func function
---@return boolean
function M.isFilterFunction(func)
    if type(func) ~= "function" then
        return false
    end
    local info = debug.getinfo(func, "u")
    if info.nparams ~= 1 then
        return false
    end
    local success, result = pcall(func, "test")
    return success and type(result) == "boolean"
end

function M.create(buffer, func)
    local lines = api.nvim_buf_get_lines(buffer, 0, -1, false)
    local filtered = {}
    for _, line in ipairs(lines) do
        if func(line) then
            table.insert(filtered, line)
        end
    end
    if #filtered > 0 then
        return filtered
    end
end

return M
