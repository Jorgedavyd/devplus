local ls = require("luasnip")
local task = require("devplus.tasks")
local logs = require("devplus.logs")

local c = ls.choice_node
local s, i, t = ls.s, ls.insert_node, ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

local config = _G.Config.tasks
local categories = config.categories
local grep_string = config.inline_format

local format_input = function (x)
    return t("%s"):format(x)
end

local day = 60 * 60 * 24

local date_default = {
    format_input(os.date(config.time_format, os.time())),
    format_input(os.date(config.time_format, os.time() + day)),
    format_input(os.date(config.time_format, os.time() + day * 2)),
    format_input(os.date(config.time_format, os.time() + day * 3)),
    format_input(os.date(config.time_format, os.time() + day * 4)),
    format_input(os.date(config.time_format, os.time() + day * 7)),
    format_input(os.date(config.time_format, os.time() + day * 14)),
    format_input(os.date(config.time_format, os.time() + day * 30)),
}

local defaults = {
    category = vim.tbl_map(format_input, categories),
    priority = vim.tbl_map(format_input, {1, 2, 3, 4, 5}),
    description = nil,
    schedule_date = date_default,
    due_date = date_default,
    start_date = date_default,
    created = nil,
    id = nil,
    recursive = {
        "every day",
        "every month",
        "every year",
        "every week on Tuesday",
        "every week on Monday",
        "every week on Sunday",
        "every week on Wednesday",
        "every week on Thursday",
        "every week on Friday",
        "every week on Saturday",
    },
}

local getOpts = function (opts)
    local out = {}
    for idx, key in ipairs(opts) do
        if key == "created" then
            table.insert(out, format_input(os.date(config.time_format, os.time())))
        elseif key == "description" or key == 'id' then
            table.insert(out, i(idx, format_input(key)))
        else
            table.insert(out, c(idx, defaults[key]))
        end
    end
end

local getFormat = function ()
    if string.find(grep_string, "category") == nil then
        logs.error("Not valid format string, cannot assign TODOs without category/namespace")
        return
    end
    local keys = vim.get_keys(task)
    local out = {}
    for _, key in ipairs(keys) do
        local i, j = string.find(grep_string, key)
        if i and j then
            table.insert(out, {[i] = string.sub(grep_string, i, j)})
        end
    end
    return grep_string, out
end

local function createSnippets(value)
    local format, opts = getFormat()
    return {
        s(
            value,
            fmt(format),
            getOpts(opts)
        )
    }
end

ls.snippets = { all = vim.tbl_map(function (x) return createSnippets(x) end, categories) }
