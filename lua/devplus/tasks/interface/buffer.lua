local decoder = require("devplus.tasks.task.decoder")
local encoder = require("devplus.tasks.task.encoder")
local config = require("devplus.setup").config.tasks
local find = require("devplus.tasks.grep")
local log = require("devplus.logs")
local api = vim.api

---@class Buffer
---@field init function
---@field virtual function
local M = {}

---@type number|nil
M.buf = nil

M.namespace = api.nvim_create_namespace("devplus-interact")

---@type table
M.paths = {}

---@param buf number
function M.jump_to_task(buf)
    local line = api.nvim_win_get_cursor(0)[1] - 1
    local tab = M.paths[buf][line]
    if tab.path and tab.line then
        api.nvim_command("e +" .. tab.line .. " " .. tab.path)
    end
end

---@private
---@param filter Filter
---@param out table
---@param buf number
---@return nil
local function setLines(out, buf, filter)
    for _, iter in ipairs(out) do
        if filter(iter.task) then
            api.nvim_buf_set_lines(buf, -1, -1, false, {decoder.buffer(iter.task)})
            local line = iter.line
            local path = iter.path
            M.paths[buf] = M.paths[buf] or {}
            table.insert(M.paths[buf], {
                line = line,
                path = path
            })
            api.nvim_buf_set_extmark(buf, M.namespace, -1, 0, {
                hl_group = "Normal",
                hl_eol = true,
                virt_text = {{" ", "Normal"}},
                virt_text_pos = "overlay",
                virt_text_win_col = 0
            })
        end
    end
end

---@private
---@param buf number
---@param filter Filter
---@return nil
function M.create(buf, filter)
    for name, _ in pairs(config.categories) do
        local lines = find.grep(name)
        local out = {}
        for _, iter in ipairs(lines) do
            local path, row, _, line = string.format(iter, "(.-):(%d+):(%d+):(.+)")
            if not path or not row or not line then
                log.warning("No tasks found")
            else
                local i, _ = string.find(line, name)
                if i then
                    table.insert(out, {
                        path = path,
                        task = encoder.inline(string.sub(line, i)),
                        line = row
                    })
                end
            end
        end
        setLines(out, buf, filter)
    end
end

---@param filter Filter
---@return number
function M.init(filter)
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'modifiable', false)
    api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    M.create(buf, filter)
    config.buffer_keymaps(buf)
    return buf
end

---@private
---@param tasks Task
---@return table<number, string>
function M.treat(tasks)
    local buf_tasks = {}
    for _, task in ipairs(tasks) do
        table.insert(buf_tasks, decoder.buffer(task))
    end
    return buf_tasks
end

---@param buf number
---@param line string
function M.append(buf, data, line, path)
    api.nvim_buf_set_lines(buf, -1, -1, false, {data})
    api.nvim_buf_set_extmark(buf, M.namespace, -1, 0, {
        hl_group = "Normal",
        hl_eol = true,
        virt_text = {{" ", "Normal"}},
        virt_text_pos = "overlay",
        virt_text_win_col = 0
    })
    M.paths[buf] = M.paths[buf] or {}
    table.insert(M.paths[buf], {
        line = line,
        path = path
    })
end

return M
