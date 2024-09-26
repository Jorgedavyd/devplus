local plot = require('tracker.plot')
---@class Setup
---@field windows table<string|number, function>
---@field buffer table<number, ...>
---@field prettier table<string, string>
---@field keymaps function
local M = {}

M.default = {
    keymaps = function ()
    end,
    vault = nil,
    project = nil,
    tasks= {
        windows = {
        },
        prettier = {
        },
        categories = {
        },
    },
    tracker = {
        aggregation = {
            plot.create()
        }, --- look at the features to pick from to create your own tracker
    },
    methods = {
        weight = function ()
        end,
    }
}

---@type table<string, function|string|table>
M.config = nil

function M.forward(opts)
    M.config = vim.tbl_deep_extend('force', opts, M.default)
end

return M

