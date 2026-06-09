---
description: "Architect/Orchestrator: Break a complex feature into implementation tasks with dependencies, estimates, and assignment recommendations."
---
# Task Decomposition

## Process
1. Read the feature/epic description
2. Identify distinct work packages
3. Determine dependencies between packages
4. Estimate effort and gas impact per package
5. Recommend agent assignment

## Output Format
```markdown
## Task Decomposition: {feature title}

### Tasks
1. **{Task title}**
   - Agent: {recommended agent}
   - Dependencies: {prior tasks}
   - Effort: {S/M/L/XL}
   - Gas impact: {estimate}
   - Deliverables: {specific outputs}

### Dependency Graph
{Mermaid flowchart of task dependencies}

### Critical Path
{Longest dependency chain}

### Parallel Opportunities
{Tasks that can run simultaneously}
```
