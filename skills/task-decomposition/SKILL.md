---
name: task-decomposition
description: "Break user requests into agent-assignable tasks with dependency DAG. Orchestrator skill for decomposing features, bugs, and requests into work items for the 9-agent team."
---
# Task Decomposition

## Purpose
Transform user requests into a directed acyclic graph of agent-assignable tasks.

## Decomposition Process

### Step 1: Classify Request
- **Feature** → Product → Architect → Developer → Tester + Security → DevOps
- **Bug fix** → Developer → Tester → DevOps (if deployment needed)
- **Security concern** → Security → Developer (if fix needed) → Tester
- **Documentation** → Docs (may involve Architect for technical content)
- **Support question** → Support (may escalate to Developer)

### Step 2: Create Task Graph
```json
{
  "id": "TASK-{NNN}",
  "type": "feature|bug|security|docs|support",
  "title": "Brief description",
  "assignee": "[AgentName]",
  "dependencies": ["TASK-{NNN}"],
  "gate": "1|2|3",
  "priority": "critical|high|medium|low",
  "acceptance_criteria": ["AC1", "AC2"],
  "status": "pending|in-progress|blocked|complete"
}
```

### Step 3: Validate DAG
- No circular dependencies
- Every task has a clear assignee
- Gate transitions have proper prerequisites
- Critical path identified

### Step 4: Delegate
- Send tasks to agent mailboxes
- Track dependencies
- Monitor progress via status dashboard

## Anti-Patterns
- Don't assign Tester tasks before Developer completes code
- Don't skip Gate 1 (requirements) for "urgent" features
- Don't assign tasks to agents outside their expertise
