local M = {}

---@return nil
function M.calculate_productivity_score()
    if M.total_time_spent > 0 then
        M.productivity_score = (M.tasks_solved / M.total_time_spent) * 100 * M.avg_priority
    else
        M.productivity_score = 0
    end
end

---@return nil
function M.reset_tracker()
    M.lines = 0
    M.tasks_solved = 0
    M.total_time_spent = 0
    M.breaks_taken = 0
    M.focus_sessions = 0
    M.max_consecutive_focus_time = 0
    M.productivity_score = 0
end

function M.ingest()
end

---@type type
return M

