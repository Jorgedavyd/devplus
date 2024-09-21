local M = {}
M.keymap = {}
M.config = {
    machines = {},
    project_config_file = ".nvim_remote_config.json",
    history_file = vim.fn.stdpath("data") .. "/ssh_command_history.json"
}

function M.call(config, cmd)
    local ssh_cmd
    if cmd then
        ssh_cmd = ("neossh -n \"%s\" -c \"%s\" -s"):format(config.host_identifier, cmd)
    else
        ssh_cmd = ("neossh -n \"%s\" -s"):format(config.host_identifier)
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
        col = math.floor(vim.o.columns * 0.1),
        row = math.floor(vim.o.lines * 0.1),
        style = 'minimal',
        border = 'rounded'
    })

    vim.fn.jobstart(ssh_cmd, {
        on_stdout = function(_, data)
            if data then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
            end
        end,
        on_stderr = function(_, data)
            if data then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
            end
        end,
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                vim.notify("SSH command completed successfully", vim.log.levels.INFO)
            else
                vim.notify("SSH command failed with exit code: " .. exit_code, vim.log.levels.ERROR)
            end
        end
    })

    M.add_to_history(cmd)
end

function M.keymap.set(letter, desc, config, cmd)
    if not config then
        vim.notify("Config not provided", vim.log.levels.ERROR)
        return
    end
    vim.keymap.set('n', ("<leader>m%s"):format(letter), function ()
        if cmd then
            M.call(config, cmd)
        else
            vim.ui.input({ prompt = config.host_identifier .. ": "}, function(command)
                if command then
                    M.call(config, command)
                else
                    vim.notify("No command provided.", vim.log.levels.WARN)
                end
            end)
        end
    end, {silent = false, noremap = true, desc = desc})
end

function M.load_project_config()
    local current_dir = vim.fn.getcwd()
    local config_path = current_dir .. '/' .. M.config.project_config_file
    local f = io.open(config_path, "r")
    if f then
        local content = f:read("*all")
        f:close()
        local ok, project_config = pcall(vim.fn.json_decode, content)
        if ok then
            M.config = vim.tbl_deep_extend("force", M.config, project_config)
        else
            vim.notify("Failed to parse project config: " .. project_config, vim.log.levels.ERROR)
        end
    end
end

function M.add_machine(name, config)
    M.config.machines[name] = config
    vim.notify("Added machine: " .. name, vim.log.levels.INFO)
end

function M.remove_machine(name)
    if M.config.machines[name] then
        M.config.machines[name] = nil
        vim.notify("Removed machine: " .. name, vim.log.levels.INFO)
    else
        vim.notify("Machine not found: " .. name, vim.log.levels.WARN)
    end
end

function M.add_to_history(cmd)
    if not cmd then return end
    local history = M.load_history()
    table.insert(history, 1, cmd)
    if #history > 50 then  -- Keep only last 50 commands
        table.remove(history)
    end
    local f = io.open(M.config.history_file, "w")
    if f then
        f:write(vim.fn.json_encode(history))
        f:close()
    end
end

function M.load_history()
    local f = io.open(M.config.history_file, "r")
    if f then
        local content = f:read("*all")
        f:close()
        local ok, history = pcall(vim.fn.json_decode, content)
        if ok then
            return history
        end
    end
    return {}
end

function M.show_history()
    local history = M.load_history()
    vim.ui.select(history, {
        prompt = "Select a command from history:",
        format_item = function(item)
            return item
        end,
    }, function(choice)
        if choice then
            vim.ui.input({ prompt = "Execute command: ", default = choice }, function(cmd)
                if cmd then
                    M.call(M.config.machines[M.config.default_machine], cmd)
                end
            end)
        end
    end)
end

function M.setup(user_config)
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
    M.load_project_config()
    vim.keymap.set('n', '<leader>mh', M.show_history, {silent = false, noremap = true, desc = "Show SSH command history"})
    user_config.keymaps(M)
end

return M
