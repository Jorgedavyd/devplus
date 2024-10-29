<div align="center">
  <h1>devplus</h1>
  <p>
    <img src="assets/logo.png" align="center" alt="Logo" />
  </p>
  <p>
    neodev tools for productivity tracking with
    <a href="https://obsidian.md/">Obsidian</a>.
  </p>
</div>

The goal of **devplus** is to provide a non-blocking framework towards developer productivity, enhancing the coding experience by seamlessly automating the interaction between Obsidian and Neovim, provide the user a versatile way to display tasks, suitable for a variety of productivity frameworks, and constant tracking of coding metrics for data informed analytics on your actionable patterns.

# Summary
The **devplus** plugin consists on:
1. Versatile task management for a variety of frameworks.
2. Constant tracking of buffer timings, task completion, lines of code created, among others.
3. Synchronization with [Obsidian](https://obsidian.md/).

# Setup
```lua
return {
    'Jorgedavyd/devplus',
    dependencies = {
        'sql', -- take a look
        'nvim-treesitter/treesitter.nvim',
        'nvim-telescope/telescope.nvim'
    },
    lazy = 1000,
    keymaps = function(_, map)
        local api = require("devplus.api")
        map('n', '-', api.toggle_ptr())
        map('n', '+', api.toggle_checkmark())
    end
}
```

# License

This project is licensed under the Apache 2.0 License - see the LICENSE file for details.

# Contact

- [Linkedin](https://www.linkedin.com/in/jorge-david-enciso-mart%C3%ADnez-149977265/)
- Email: jorged.encyso@gmail.com
- [GitHub](https://github.com/Jorgedavyd)


