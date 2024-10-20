local previewer = require("telescope.previewers")

local M = {}

local prev = previewer.new(opts or {})

--- on movement in the M.buffers.bufnrs
--- we should previewer.buffer_previewer_maker(task.filepath, prev_bufnr, opts)
--- the picker should be created with the previewer created here, and the bufnr should be store
--- This way, every time the cursor moves vertically, I can trigger the task in buffer line to
--- be shown on the previewer with, so I would be using one previewer with different buffers
--- triggering the action, making an abstraction on top of the default actions that are allowed
--- TODO Further analize what's inside actions, cause it could be helpful, also, don't close telescope
--- until the real keybinding is pressed, try to integrate all windows to be displayed simultaneusly
return M
