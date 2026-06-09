---
name: status-reporting
description: "Synthesize team progress into user-facing reports. Aggregate agent statuses, task completion, blocker summaries, and quality gate status for the Orchestrator to present."
---
# Status Reporting

## Report Template

```markdown
## Team Status Report — {date}

### Active Tasks
| Task | Agent | Status | Gate | Blockers |
|------|-------|--------|------|----------|

### Quality Gates
- Gate 1: {status}
- Gate 2: {status}
- Gate 3: {status}

### Key Decisions Made
- {decision with justification}

### Blockers & Risks
- {blocker: responsible agent, mitigation}

### Next Steps
1. {next action}
```

## Report Frequency
- On demand (user asks for status)
- At gate transitions
- When blockers arise
- At milestone completion

## Data Sources
- `docs/status/dashboard.json` — overall status
- `docs/tasks/` — individual task status
- Agent mailboxes — latest messages
