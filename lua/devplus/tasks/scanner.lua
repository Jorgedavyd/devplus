local parsers = require("nvim-treesitter.parsers")
local logs = require("devplus.logs")
local encoder = require("devplus.tasks.encoder")
local categories = require("devplus.setup").config.tasks.categories
local cache = require("devplus.tasks.cache")

local M = {}

function M.process_categories()
    local output = {}
    for name, _ in pairs(categories) do
        table.insert(output, name)
    end
    return output
end

function M.current_update()
    local category_pattern = table.concat(M.process_categories(), "|")
    local query = string.format([[
    (((comment) @comment)
        (#match? @comment "%s"))
    ]], category_pattern)
    local parser = parsers.get_parser()
    if not parser then
        logs.error("Treesitter parser not found")
        return
    end
    local tree = parser:parse()[1]
    local root = tree:root()
    local language = parser:lang()
    local parsed_query = vim.treesitter.query.parse(language, query)
    local output = {}
    for _, matches, _ in parsed_query:iter_matches(root, 0) do
        for _, match in ipairs(matches) do
            if match then
                local text = vim.treesitter.get_node_text(match, 0)
                if text then
                    local task = encoder.buffer(text)
                    if task then
                        table.insert(output, task)
                    end
                end
            end
        end
    end
    if output then
        cache.append(output)
    end
end

return M

