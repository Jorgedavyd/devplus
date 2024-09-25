---@class Prettier
---@field signs table<string, string>
local M = {}

---@type table<string, string>
M.config = {}

function M.()
end

function M.update()

end

function M.opts()
    return {
        end_line = end_line,
        id = 1,
        virt_text = virt_text,
        virt_text_post = 'overlay',
    }
end
return M
