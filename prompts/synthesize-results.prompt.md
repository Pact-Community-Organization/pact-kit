---
description: "Orchestrator: Combine results from multiple agents into a coherent user-facing response. Aggregate findings, verdicts, and recommendations."
---
# Synthesize Results

## Input
- Results from multiple agent tasks
- Quality gate status
- Any blockers or findings

## Process
1. Collect all agent outputs
2. Check for conflicts or contradictions
3. Resolve or escalate conflicts
4. Aggregate findings by severity
5. Determine overall status

## Output Format
```markdown
## Results Summary

### Status: {COMPLETE | BLOCKED | IN-PROGRESS}

### Agent Reports
- [Architect]: {summary}
- [Developer]: {summary}
- [Tester]: {verdict — GO/NO-GO}
- [Security]: {verdict — APPROVE/REJECT}

### Findings
| Severity | Count | Details |
|----------|-------|---------|
| CRITICAL | N | ... |
| HIGH | N | ... |

### Next Steps
1. {action item}
```
