local M = {}

---@class Tracker
---@field show function
---@field show_day function
M.tracker = {}

---@param interval {begin:string, final:string}
---@param resolution string
---@return nil
function M.tracker.show(interval, resolution)
end

---@param date string
---@return nil
function M.tracker.show_day(date, resolution)
end
