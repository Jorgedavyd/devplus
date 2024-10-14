local api = vim.api
--- database ingestion for all triggers that were counted

local id = api.nvim_create_augroup("devplus-tracker")

---@class BufferTracker
---@field status table
local M = {}

M.status = {}

--- Buffer wise: Tracks the number of lines added and deleted,
--- the time that you were at the buffer.

--- ON DEATACH
function M.getAddedLines()
end

function M.getDeletedLines()
end

function M.getTime()
end

--- ON ATTACH

api.nvim_create_autocmd(
    {"BufWinEnter"},
    {
        group = id,
    }
)

api.nvim_create_autocmd(
    {"BufWinLeave"},
    {
        group = id,
    }
)

return M
