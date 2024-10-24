require("devplus.autocmd")
require("devplus.database")
require("devplus.tasks")
require("devplus.cmp")

local setup = require("devplus.setup")

local M = {}

M.setup = function (opts)
    setup.forward(opts)
end

return M
