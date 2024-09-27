---@alias TaskDailyRecord table <string, number>
---@class FeatureEngineering
---@field calculate_productivity_score function
---@field weighted_harmonic_mean function
---@field calculate_efficiency_ratio function
---@field calculate_task_completion_rate function
---@field calculate_priority_alignment function
---@field calculate_time_management_index function
local M = {}

---@return nil
function M.calculate_productivity_score(total_time_spent, tasks_solved, avg_priority)
    local productivity_score
    if total_time_spent > 0 then
        productivity_score = (tasks_solved / total_time_spent) * 100 * avg_priority
    else
        productivity_score = 0
    end
    return productivity_score
end

---@return number
function M.calculate_efficiency_ratio(estimated_time, total_time_spent)
    if estimated_time > 0 then
        return total_time_spent / estimated_time
    else
        return 0
    end
end

---@return number
function M.calculate_task_completion_rate(total_tasks, tasks_solved)
    if total_tasks > 0 then
        return tasks_solved / total_tasks
    else
        return 0
    end
end

---@return number
function M.calculate_priority_alignment(high_priority_tasks_completed, total_tasks)
    if total_tasks > 0 then
        return high_priority_tasks_completed / total_tasks
    else
        return 0
    end
end

---@return number
function M.calculate_time_management_index(estimated_time, total_time_spent)
    local planned_time = estimated_time or 0
    local actual_time = total_time_spent or 0
    if planned_time > 0 then
        return (planned_time - math.abs(planned_time - actual_time)) / planned_time
    else
        return 0
    end
end

M.list = {
    M.calculate_productivity_score,
    M.calculate_efficiency_ratio,
    M.calculate_task_completion_rate,
    M.calculate_priority_alignment,
    M.calculate_time_management_index,
}

return M
