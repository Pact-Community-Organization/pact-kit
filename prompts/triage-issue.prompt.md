---
description: "Support: Triage an incoming issue or bug report. Classify, prioritize, and route to the appropriate agent."
---
# Triage Issue

## Triage Steps
1. Read the issue description
2. Attempt to reproduce or understand the problem
3. Classify by type (bug, feature, security, docs, SDK)
4. Assess severity (P0-P3)
5. Check for duplicates
6. Route to appropriate agent

## Output
```markdown
## Triage — #{issue_number}: {title}

### Classification
- Type: {Bug | Feature | Security | Docs | SDK}
- Severity: {P0 | P1 | P2 | P3}
- Reproducible: {Yes | No | Need Info}

### Analysis
{Brief analysis of the issue}

### Affected Components
- Module: {module name}
- Function: {function if identified}

### Duplicate Check
- Similar: {#issue numbers or "None found"}

### Routing
→ {[AgentName]}: {brief reason}

### Notes
{Additional context or quick workaround}
```
