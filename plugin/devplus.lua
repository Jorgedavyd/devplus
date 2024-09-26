if vim.g.loaded_your_plugin then
  return
end
vim.g.loaded_your_plugin = true

vim.api.nvim_create_user_command('ToggleTasks', function()

end, {})

vim.api.nvim_create_user_command('ToggleTracker', function()

end, {})
