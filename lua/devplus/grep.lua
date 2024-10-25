local M = {}

local config = {
    max_results = 1000,
    exclude_dirs = { '.git', 'node_modules', 'target', 'build', 'dist' },
    exclude_files = { '*.pyc', '*.class', '*.o' },
    case_sensitive = false,
    use_ripgrep = vim.fn.executable('rg') == 1,
    use_fd = vim.fn.executable('fd') == 1,
    search_hidden = false,
}

local function escape_pattern(text)
    return text:gsub('([^%w])', '%%%1')
end

local function get_ripgrep_cmd(pattern, path)
    local cmd = {'rg', '--color=never', '--no-heading', '--line-number'}

    if not config.case_sensitive then
        table.insert(cmd, '--ignore-case')
    end

    if config.search_hidden then
        table.insert(cmd, '--hidden')
    end

    for _, dir in ipairs(config.exclude_dirs) do
        table.insert(cmd, '--glob')
        table.insert(cmd, '!' .. dir)
    end

    for _, file in ipairs(config.exclude_files) do
        table.insert(cmd, '--glob')
        table.insert(cmd, '!' .. file)
    end

    table.insert(cmd, '--')
    table.insert(cmd, pattern)

    if path then
        table.insert(cmd, path)
    end

    return cmd
end

function M.grep_sync(pattern, path)
    path = path or '.'
    local results = {}

    if config.use_ripgrep then
        local cmd = get_ripgrep_cmd(pattern, path)
        local output = vim.fn.system(cmd)

        for line in output:gmatch('[^\r\n]+') do
            local file, lnum, text = line:match('([^:]+):(%d+):(.+)')
            if file and lnum and text then
                table.insert(results, {
                    filename = file,
                    lnum = tonumber(lnum),
                    text = text:gsub('^%s+', '')
                })
            end
        end
    else
        local escaped_pattern = escape_pattern(pattern)
        vim.cmd('noautocmd vimgrep /' .. escaped_pattern .. '/j ' .. path .. '/**/*')

        for _, item in ipairs(vim.fn.getqflist()) do
            if #results < config.max_results then
                table.insert(results, {
                    filename = vim.fn.bufname(item.bufnr),
                    lnum = item.lnum,
                    text = item.text:gsub('^%s+', '')
                })
            else
                break
            end
        end
    end

    return results
end

function M.grep_async(pattern, path, callback)
    path = path or '.'

    if not config.use_ripgrep then
        callback(M.grep_sync(pattern, path))
        return
    end

    local cmd = get_ripgrep_cmd(pattern, path)
    local tasks = {}
    local job_id

    local on_stdout = function(_, data)
        if data then
            for _, line in ipairs(data) do
                if line ~= '' then
                    local file, lnum, text = line:match('([^:]+):(%d+):(.+)')
                    if file and lnum and text then
                        table.insert(tasks, {
                            opts = {
                                filename = file,
                                lnum = tonumber(lnum),
                                text = text:gsub('^%s+', '')
                            }
                        })
                    end
                end
            end
        end
    end

    local on_exit = function()
        callback(results)
    end

    job_id = vim.fn.jobstart(cmd, {
        on_stdout = on_stdout,
        on_exit = on_exit,
        stdout_buffered = true
    })

    return job_id
end

-- Fuzzy find files
function M.fuzzy_find(query, path)
    path = path or '.'
    local results = {}

    if config.use_fd then
        local cmd = {'fd', '--type', 'f', '--color', 'never'}

        if config.search_hidden then
            table.insert(cmd, '--hidden')
        end

        -- Add exclude patterns
        for _, dir in ipairs(config.exclude_dirs) do
            table.insert(cmd, '--exclude')
            table.insert(cmd, dir)
        end

        if query then
            table.insert(cmd, query)
        end

        table.insert(cmd, path)

        local output = vim.fn.system(cmd)
        for line in output:gmatch('[^\r\n]+') do
            table.insert(results, line)
        end
    else
        -- Fallback to find
        local find_cmd = string.format(
            'find %s -type f %s %s',
            path,
            config.search_hidden and '' or '-not -path "*/\\.*"',
            query and string.format('-name "*%s*"', query) or ''
        )

        local output = vim.fn.system(find_cmd)
        for line in output:gmatch('[^\r\n]+') do
            table.insert(results, line)
        end
    end

    return results
end

function M.setup(opts)
    config = vim.tbl_deep_extend('force', config, opts or {})
end

return M
