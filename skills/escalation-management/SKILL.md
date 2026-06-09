---
name: escalation-management
description: "Handle blockers, inter-agent conflicts, ambiguous requirements, and stalled tasks. Escalation pathways and resolution patterns for the Orchestrator."
---
# Escalation Management

## Escalation Triggers
1. **Blocker** — Agent cannot proceed due to dependency
2. **Conflict** — Two agents disagree on approach
3. **Ambiguity** — Requirement unclear, multiple interpretations
4. **Stall** — Task not progressing for extended period
5. **Veto** — Tester NO-GO or Security CRITICAL

## Resolution Pathways

### Blocker Resolution
1. Identify blocking agent and specific dependency
2. Can the blocker be resolved in parallel?
3. Can the blocked task proceed with documented assumptions?
4. If neither → reprioritize the blocking task

### Conflict Resolution
1. Gather both positions with evidence
2. Check if specification resolves the conflict
3. If not → Architect provides technical ruling
4. If architectural → escalate to user for business decision

### Veto Handling
- Tester NO-GO: Developer MUST address findings before re-review
- Security CRITICAL: No override possible — must fix or get explicit user waiver
- User may override Tester NO-GO with documented risk acceptance
