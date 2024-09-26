---@param s string
---@param value string
---@return boolean
function string.endswith(s, value)
    local ending = string.sub(s, #s - #value, #s)
    return ending == value
end
