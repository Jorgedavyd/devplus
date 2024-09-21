local M = {}

---@type number
M.lines = 0  -- Total lines of code written

---@type number
M.tasks_solved = 0  -- Total tasks or problems solved

---@type number
M.total_time_spent = 0  -- Total time spent on tasks (in minutes)

---@type number
M.breaks_taken = 0  -- Total number of breaks taken

---@type number
M.focus_sessions = 0  -- Total number of focused work sessions

---@type number
M.max_consecutive_focus_time = 0  -- Maximum time spent in a single focus session (in minutes)

---@type number
M.productivity_score = 0  -- A score calculated based on completed tasks, time spent, and focus sessions

---@type type
return M
