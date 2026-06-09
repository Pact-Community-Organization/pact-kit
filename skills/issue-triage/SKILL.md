---
name: issue-triage
description: "Bug and issue classification, priority routing, and initial diagnosis for Pact Community projects. Triage protocol for incoming issues and bug reports."
---
# Issue Triage

## Classification
| Type | Label | Route To | Priority |
|------|-------|----------|----------|
| Security vulnerability | `security` | Security | P0/P1 |
| Transaction failure | `bug` | Developer | P1 |
| Gas exceeded | `gas` | Developer + Architect | P2 |
| SDK integration issue | `sdk` | Support → Developer | P2 |
| Documentation gap | `docs` | Docs | P3 |
| Feature request | `enhancement` | Product | P3 |

## Triage Checklist
1. Reproduce the issue (or gather reproduction steps)
2. Classify by type and severity
3. Check for duplicates
4. Add appropriate labels
5. Route to correct agent via Orchestrator

## Initial Diagnosis
```markdown
## Triage — Issue #{N}
Reporter: {who}
Type: {classification}
Priority: {P0-P3}
Reproducible: {Yes/No/Need Info}
Affected: {module/package}
Summary: {1-2 sentence description}
Route: → {AgentName}
```
