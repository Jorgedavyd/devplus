local parsers = require("nvim-treesitter.parsers")
local encoder = require("devplus.tasks.encoder")
local categories = require("devplus.setup").config.tasks.categories
local cache = require("devplus.tasks.cache")

local M = {}

function M.processs_categories()
    local output = {}
    for name, _ in pairs(categories) do
        table.insert(output, name)
    end
    return vim.iter(output)
end

function M.current_update()
    local query =([[
    (((comment) @comment)
        (#match? @comment "%s"))
    ]]):format(M.processs_categories():join("|"))
    local parser = parsers.get_parser()
    local tree = parser:parse()[1]
    local root = tree:root()
    local language = parser:lang()
    local parsed_query = vim.treesitter.query.parse(language, query)
    for _, matches, _ in parsed_query:iter_matches(root, 0) do
        for _, match in ipairs(matches) do
            if match then
                local task = encoder.buffer(vim.treesitter.get_node_text(match, 0))
                if task then
                    cache.append(task)
                end
            end
        end
    end
end

return M
