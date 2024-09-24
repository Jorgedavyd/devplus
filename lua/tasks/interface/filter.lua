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

return M
