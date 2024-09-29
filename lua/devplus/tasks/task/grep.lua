local api = vim.api
local M = {}

---@param category string
---@return table<number, string>
function M.grep(category)
    local grep_cmd = vim.fn.executable('rg') == 1 and 'rg --vimgrep' or 'grep -Rn'
    local pattern = ([[\b%s]]):format(category)
    local cmd = string.format("%s %s .", grep_cmd, pattern)
    local output = vim.fn.system(cmd)
    return vim.split(output, '\n')
end

---@param line string
---@param buf number
---@return nil
function M.change(line, buf)
    api.nvim_buf_set_lines(buf, -1, -1, false, {line})
end


---@param lines table<number, string>
---@param buf number
---@return nil
function M.create(lines, buf, filter)
    for _, line in pairs(lines) do
        if filter(line) then
            api.nvim_buf_set_lines(buf, -1, -1, false, {line})
        end
    end
end

return M
