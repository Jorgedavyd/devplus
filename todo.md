:h telescope.setup
:h telescope.command
:h telescope.builtin
:h telescope.themes
:h telescope.layout
:h telescope.resolve
:h telescope.actions
:h telescope.actions.state
:h telescope.actions.set
:h telescope.actions.utils
:h telescope.actions.generate
:h telescope.actions.history
:h telescope.previewers

previewers.vim_buffer_cat()            *telescope.previewers.vim_buffer_cat()*
    A previewer that is used to display a file. It uses the `buffer_previewer`
    interface and won't jump to the line. To integrate this one into your own
    picker make sure that the field `path` or `filename` is set for each entry.
    The preferred way of using this previewer is like this
    `require('telescope.config').values.file_previewer` This will respect user
    configuration and will use `termopen_previewer` in case it's configured
    that way.



