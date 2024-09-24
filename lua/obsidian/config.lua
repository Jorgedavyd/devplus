---@class M This is the config instance
---@field vault string Defines the path towards the Obsidian vault.
---@field project string Defines the relative path towards the task Obsidian storage.
---@field database string Defines the absolute path towards the devplus database where the metrics are stored
local M = {}

M.vault = "~"
M.project = "projects/"
M.database = "devplus.json"

return M
