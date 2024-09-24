local logs = require("logs")
local buffer = require("buffer")
local filter = require("filter")
---@class Windows
---@field filter function
---@field create function
---@field config table<string, function>
local M = {}

---@type table<string, Filter>
M.config = {
    function ()

    end,
    function ()

    end,
}

---@private
---@param opts table<number|string, function>
function M.assert(opts)
    local len = #opts
    if len <= 4 then
        logs.error("Not valid window config, expected at most 4 windows, got" .. len)
        return
    elseif len == 0 then
        logs.error("Void windows launch parameters, expected at least 1, got" .. len)
    end
    for idx, func in pairs(opts) do
        if !filter.isFilterFunction(func) then
            logs.error("Not valid function at function" .. idx .. " in windows config, expected a function(task) -> boolean")
        end
    end
end

---@private
---@param config table<number|string, function>
---@return table<number|string, function>
function M.setWindows(config)
    M.assert(config)
    for _, window in pairs(M.config) do
        window
    end
    return flag
end

---@return nil
function M.create()
    local buf = buffer.buf
    M.setWindows(M.config)
end

return M
