local params = require("params")
---@class FeatureEngineering
---@field calculate_productivity_score function
---@field weighted_harmonic_mean function
---@field calculate_efficiency_ratio function
---@field calculate_task_completion_rate function
---@field calculate_priority_alignment function
---@field calculate_time_management_index function
local M = {}

---@param task table <string, string|number>
---@return nil
function M.calculate_productivity_score(task)
    if task.total_time_spent > 0 then
        task.productivity_score = (task.tasks_solved / task.total_time_spent) * 100 * task.avg_priority
    else
        task.productivity_score = 0
    end
end

---@private
---@param x1 number
---@param x2 number
---@param a number
---@param b number
---@return number
function M.weighted_harmonic_mean(x1, x2, a, b)
    x1 = x1 * a
    x2 = x2 * b
    return (x1 + x2) / (1/x1 + 1/x2)
end

---@param task table <string, string|number>
---@return number
function M.calculate_efficiency_ratio(task)
    if task.estimated_time > 0 then
        return task.total_time_spent / task.estimated_time
    else
        return 0
    end
end

---@param task table <string, string|number>
---@return number
function M.calculate_task_completion_rate(task)
    if task.total_tasks > 0 then
        return task.tasks_solved / task.total_tasks
    else
        return 0
    end
end

---@param task table <string, string|number>
---@return number
function M.calculate_priority_alignment(task)
    if task.total_tasks > 0 then
        return task.high_priority_tasks_completed / task.total_tasks
    else
        return 0
    end
end

---@param task table <string, string|number>
---@return number
function M.calculate_time_management_index(task)
    local planned_time = task.estimated_time or 0
    local actual_time = task.total_time_spent or 0
    if planned_time > 0 then
        return (planned_time - math.abs(planned_time - actual_time)) / planned_time
    else
        return 0
    end
end

---@param task table <string, string|number>
---@return table <string, number>
function M.compute(task)
    local metrics = {}
    M.calculate_productivity_score(task)
    metrics.productivity_score = task.productivity_score
    metrics.efficiency_ratio = M.calculate_efficiency_ratio(task)
    metrics.task_completion_rate = M.calculate_task_completion_rate(task)
    metrics.priority_alignment = M.calculate_priority_alignment(task)
    metrics.time_management_index = M.calculate_time_management_index(task)
    metrics.composite_score = M.weighted_harmonic_mean(
        metrics.productivity_score,
        metrics.efficiency_ratio * 100,
        params.alpha,
        params.beta
    )
    return metrics
end

return M
