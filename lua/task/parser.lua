
local M = {}

---@type string
M.comment_pattern = "TODO%s+(%d%d%d%d%d%d)%s+([A-Z])%s+(.*)"

---@param single_comment string
---@return table|nil
function M.get_task(single_comment)
    local group = single_comment:match(M.comment_pattern)
    if group then
        return {
            due_date = group[1],
            priority = group[2],
            description = group[3]
        }
    end
end

---@private
---@param filepath string
---@return table<number,string>|nil
function M.getFileTasks(filepath)
    vim.api.nvim_get_current_win()
end

return M
