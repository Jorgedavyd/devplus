local config = require("setup").config.harmonic_mean
---@class Params
---@field alpha number Weight for x_1 parameter for the weighted harmonic mean estimation
---@field beta number Weight for x_1 parameter for the weighted harmonic mean estimation

local M = {
    alpha = 1,
    beta = 1
}

return vim.tbl_deep_extend('force', config, M)
