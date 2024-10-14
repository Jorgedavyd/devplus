local M = {}
---@private
---@param iterables table
---@return table
function M.chain_from_iterable(iterables)
    local result = {}
    for _, iterable in ipairs(iterables) do
        for _, value in ipairs(iterable) do
            table.insert(result, value)
        end
    end
    return result
end

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

return M
