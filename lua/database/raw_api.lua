local config = require("lua.obsidian.config")
local builtin = require("telescope.builtin")
local M = {}

---@type string
M.pattern = "- [ ] %s %s%s %s%s"

---@private
---@return table <string,string>|nil
function M.readDataset()
    if vim.fn.filereadable(config.database) == 0 then
        print("File not found: " .. config.database)
        return
    end
    local content = vim.fn.json(vim.fn.readfile(config.database), "\n")
    local status, result = pcall(vim.fn.json_decode, content)
    if status then
        return result
    end
end

---@private
---@param database table <number,table <string, string|number>>
---@return boolean
function M.writeDataset(database)
    local status, _ = pcall(vim.fn.json_encode, database)
    return status
end

---@param tasks table
---@return nil | boolean
function M.POST(tasks)
    local database = M.readDataset() or {}
    database = vim.tbl_extend(database, tasks)
    local status = M.writeDataset(database)
    local out = status or nil
    return out
end

---@param file string
---@return table <string, string>|nil
function M.GET(file)
    local database = M.readDataset()
    if database then
        for _, value in ipairs(database) do
            if value["file"] == file then
                return value
            end
        end
    end
end

---@private
---@param String string
---@param Start string
---@return boolean
function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

---@private
---@param file table
---@return table
function M.parse (file)
    local tasks = {}
    local group
    for _, line in pairs(file) do
        if string.starts(line, '- [ ]') then
            group = line:match(M.pattern)
        end
        table.insert(tasks, {
            due_date = group[0],
            priority = group[1],
            description = group[2]
        })
    end
    return tasks
end

return M
