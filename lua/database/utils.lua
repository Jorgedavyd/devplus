local config = require("obsidian.config")
---@class IO
---@field dump function
---@field load function
local M = {}

---@param data {file?:{}}
---@return nil
function M.dump(data)
    local database = M.readFile(config.database)
    database = vim.tbl_deep_extend(database, data, 'force')
    M.writeFile(config.database, database);
end

---@return table <number, {file?:{}}>
function M.load()
    return M.readFile(config.database)
end

---Non blocking IO operations for database handling

---@private
---@param file string
---@return table <number, {file?: {}}>
function M.readFile(file)

    return
end

---@private
---@param file string
---@param data table<number,{file?:{}}>
---@return nil
function M.writeFile(file, data)
end


