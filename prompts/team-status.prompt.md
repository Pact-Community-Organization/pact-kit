---
description: "Orchestrator: Generate a team status report showing all active tasks, agent assignments, quality gate progress, and blockers."
---
# Team Status

## Process
1. Read `docs/status/dashboard.json`
2. Read active tasks from `docs/tasks/`
3. Check agent mailboxes for latest messages
4. Compile status report

## Output Format
```markdown
## Team Status — {date}

### Active Tasks
| Task | Agent | Status | Gate | Blockers |
|------|-------|--------|------|----------|

### Quality Gates
- Gate 1 (Pre-Code): {status}
- Gate 2 (Pre-Merge): {status}
- Gate 3 (Pre-Deploy): {status}

### Agent Status
| Agent | Current Task | Workload |
|-------|-------------|----------|

### Blockers
- {blocker description → responsible agent}

### Decisions Needed
- {decision requiring user input}
```
