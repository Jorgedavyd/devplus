local log = require("devplus.logs")
local image = require("image")
---@class Plotter
local M = {}

---@private
---@param filters table <number, function | table <number, function>>
---@return table<number, table<string, number>> | table<number, table<number, table <string, number>>>
function M.getImagePos(filters, idx, row_size)
    local positions = {}
    local range = #filters
    if type(filters[1]) == "table" then
        assert(type(idx) == "nil", "Not valid keyword idx for nested table")
        assert(type(row_size) == "nil", "Not valid keyword len for nested table")
        for i=1,range do
            table.insert(positions, M.getImagePos(filters, i, range))
        end
    else
        local height, width = vim.o.lines, math.floor(vim.o.columns * 5 / 8)
        local shift = vim.o.columns - width
        for i=1,range do
            table.insert(positions, {
                width = math.floor(height / row_size),
                height = math.floor(width / range),
                row = idx,
                col = shift + i,
                func = filters[i]
            })
        end
    end
    return positions
end

function M.show(opts)
    M.create_plots(opts.func)
    local img = image.from_file(vim.stdpath('data') .. '/images/' .. opts.name)
    img:render({
        x = opts.col,
        y = opts.row,
        width = opts.width,
        heigt = opts.height
    })
    img:brightness(opts.brightness)
    img:saturation(opts.saturation)
    img:hue(opts.hue)
end

function M.plot_assert(filters, opts)
    if !(#filters == #opts) then
        log.error("Not valid filters and options")
    end
end

function M.create_plots(filters, opts)
    for name, filter in pairs(filters) do
        vim.fn.SeabornPlot(opts.width, opts.height, name)
    end
end

function M.toggle_plot(filters, opts)
    M.plot_assert(filters, opts)
    for i=1,#opts do
        if type(filters[i]) == 'table' then
            M.toggle_plot(filters[i], opts[i])
        elseif type(filters[i]) == 'function' then
            M.show({
            })
        end
    end
end

return M
