require("devplus.autocmd")
local setup = require("devplus.setup")

local M = {}

M.setup = function (opts)
    setup.forward(opts)
end

return M
