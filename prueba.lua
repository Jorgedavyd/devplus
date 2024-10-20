local previewer = require("telescope.previewers")

local new_previewer = previewer.Previewer:new(opts)

new_previewer:preview()
--[[
- `:new(opts)`
    - `:preview(entry, status)`
    - `:teardown()`
    - `:send_input(input)`
    - `:scroll_fn(direction)`
previewers.buffer_previewer_maker({filepath}, {bufnr}, {opts}) *telescope.previewers.buffer_previewer_maker()*

previewers.new_buffer_previewer() *telescope.previewers.new_buffer_previewer()*
    An interface to instantiate a new `buffer_previewer`. That means that the
    content actually lives inside a vim buffer which enables us more control
    over the actual content. For example, we can use `vim.fn.search` to jump to
    a specific line or reuse buffers/already opened files more easily. This
    interface is more complex than `termopen_previewer` but offers more
    flexibility over your content. It was designed to display files but was
    extended to also display the output of terminal commands.

previewers.vim_buffer_cat()            *telescope.previewers.vim_buffer_cat()*
    A previewer that is used to display a file. It uses the `buffer_previewer`
    interface and won't jump to the line. To integrate this one into your own
    picker make sure that the field `path` or `filename` is set for each entry.
    The preferred way of using this previewer is like this
    `require('telescope.config').values.file_previewer` This will respect user
    configuration and will use `termopen_previewer` in case it's configured
    that way.

previewers.display_content()          *telescope.previewers.display_content()*
    A deprecated way of displaying content more easily. Was written at a time,
    where the buffer_previewer interface wasn't present. Nowadays it's easier
    to just use this. We will keep it around for backwards compatibility
    because some extensions use it. It doesn't use cache or some other clever
    tricks.








    ]]--


