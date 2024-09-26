---@class Setup
---@field windows table<string|number, function>
---@field buffer table<number, ...>
---@field prettier table<string, string>
---@field keymaps function
local M = {}

M.default = {
    prettier = {

    },
    windows = {

    },
    keymaps = {

    },
    vault = "~",
    project = "projects/",
}


M.config = nil

function M.forward(opts)
    M.config = vim.tbl_deep_extend('force', opts, M.default)
end

return M

