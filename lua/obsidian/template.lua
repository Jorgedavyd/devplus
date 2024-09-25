---@class Template
---@field todo table <number,string>
---@field main string
local M = {}

M.todo = {
    "***",
    "path: {{PATH_PLACEHOLDER}}",
    "{{TASK_PLACEHOLDER}}",
    "```{{LANGUAGE_PLACEHOLDER}}",
    "{{CODE_BLOCK_PLACEHOLDER}}",
    "```",
    "{{AI_SOLUTION_PLACEHOLDER}}"
}

M.main = [[
# Important/Urgent
```tasks
path includes {{PROJECT_PLACEHOLDER}}
due in or before this week
scheduled in or before this week
(priority is high) OR (priority is highest)
not done
```
# Not_important/Urgent
```tasks
path includes {{PROJECT_PLACEHOLDER}}
due in or before this week
scheduled in or before this week
(priority is low) OR (priority is medium)
not done
```
# Important/Not_urgent
```tasks
path includes {{PROJECT_PLACEHOLDER}}
due after this week
scheduled after this week
(priority is high) OR (priority is highest)
not done
```
# Not_important/Not_urgent
```tasks
path includes {{PROJECT_PLACEHOLDER}}
due after this week
scheduled after this week
(priority is low) OR (priority is medium)
not done
```
# Not defined
```tasks
path includes {{PROJECT_PLACEHOLDER}}
(no due date) AND (no scheduled date)
not done
```
]]

M.todo_default = {
    ["{{PATH_PLACEHOLDER}}"] = "path",
    ["{{TASK_PLACEHOLDER}}"] = "task",
    ["{{LANGUAGE_PLACEHOLDER}}"] = "language",
    ["{{CODE_BLOCK_PLACEHOLDER}}"] = "code",
}

return M
