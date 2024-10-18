--local categories = require("devplus.setup").config.tasks.categories
local categories = {'TODO', 'DATA'}

-- TODO hola
-- DATA hola

local language = vim.bo.filetype
local new_categories = vim.iter(categories):map(function (value)
    return ("\"%s\""):format(value)
end)

local query = ([[
    (((comment) @comment)
        (#any-match? @comment %s))
    ]]):format(new_categories:join(" "))

local parsed_query = vim.treesitter.query.parse(language, query)

