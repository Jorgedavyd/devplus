local ls = require("luasnip")
local task = require("devplus.tasks")
local logs = require("devplus.logs")

local s = ls.s
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

local config = _G.Config.tasks
local categories = config.categories
local grep_string = config.inline_format
local DAY_SECONDS = 60 * 60 * 24

-- Helper functions
local function format_input(x)
    return t(tostring(x))
end

local function get_future_date(days_ahead)
    return format_input(os.date(config.time_format, os.time() + (DAY_SECONDS * days_ahead)))
end

local date_defaults = {
    get_future_date(0),
    get_future_date(1),
    get_future_date(2),
    get_future_date(3),
    get_future_date(4),
    get_future_date(7),
    get_future_date(14),
    get_future_date(30)
}

local defaults = {
    category = vim.tbl_map(format_input, categories),
    priority = vim.tbl_map(format_input, {1, 2, 3, 4, 5}),
    description = nil,
    schedule_date = date_defaults,
    due_date = date_defaults,
    start_date = date_defaults,
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
    }
}

local function get_format()
    if not string.find(grep_string, "category") then
        logs.error("Invalid format string: TODOs require a category/namespace")
        return nil, nil
    end
    grep_string, _ = string.gsub(grep_string, "{", "{{")
    grep_string, _ = string.gsub(grep_string, "}", "}}")
    local format_keys = {}
    for key in vim.iter(task) do
        local start_pos, end_pos = string.find(grep_string, key)
        if start_pos and end_pos then
            table.insert(format_keys, {
                key = key,
                start_pos = start_pos,
                end_pos = end_pos,
                text = string.sub(grep_string, start_pos, end_pos)
            })
            grep_string, _ = string.gsub(grep_string, key, "{}")
        end
    end
    table.sort(format_keys, function(a, b) return a.position < b.position end)
    local ordered_keys = vim.tbl_map(function(item) return item.key end, format_keys)
    return grep_string, ordered_keys
end

local function get_opts(format_keys)
    if not format_keys then return {} end

    local options = {}
    for idx, key in ipairs(format_keys) do
        if key == "created" then
            table.insert(options, format_input(os.date(config.time_format, os.time())))
        elseif key == "description" or key == 'id' then
            table.insert(options, i(idx, key))
        elseif defaults[key] then
            table.insert(options, c(idx, defaults[key]))
        else
            logs.warning(string.format("Unknown key in format string: %s", key))
        end
    end
    return options
end

local function create_snippets(trigger)
    local format, format_keys = get_format()
    if not format then return {} end

    return {
        s(trigger, fmt(format, get_opts(format_keys)))
    }
end

ls.snippets = {
    all = vim.tbl_map(create_snippets, categories)
}

return ls.snippets
