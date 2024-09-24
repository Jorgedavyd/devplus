
local M = {}

---@return nil
function M.buffer()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "Tasks")
end


---@type table <string,function>
M.windows = {}

function M.windows.urgentImportant()

end

function M.windows.notUrgentImportant()
end

function M.windows.urgentNotImportant()

end

function M.windows.notUrgentNotImportant()

end
return M


