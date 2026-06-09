---
name: dependency-resolution
description: "Track task dependencies, detect cycles, identify critical path, and manage blocked tasks in the multi-agent workflow. Prevents deadlocks in agent coordination."
---
# Dependency Resolution

## Dependency Types
- **Hard** — Task B cannot start until Task A completes
- **Soft** — Task B benefits from Task A but can proceed with assumptions
- **Gate** — Task B requires gate approval (Tester GO, Security APPROVE)

## Cycle Detection
Before assigning tasks, verify no circular dependencies exist:
1. Build adjacency list from task dependencies
2. Run topological sort
3. If sort fails → cycle detected → restructure tasks

## Critical Path
1. Identify the longest chain of hard dependencies
2. Prioritize critical-path tasks
3. Parallelize non-critical tasks where possible

## Blocked Task Protocol
1. Identify the blocker
2. Notify the blocking agent via mailbox
3. Escalate to Orchestrator if blocker persists > 1 cycle
4. Consider workaround: can the blocked task proceed with assumptions?
