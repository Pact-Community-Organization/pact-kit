---
description: "Architect: Review an architecture proposal or ADR for completeness, gas feasibility, KDA-CE compliance, and cross-module impact."
---
# Architecture Review

## Review Checklist
- [ ] Gas budget within 150k per transaction
- [ ] Module dependency DAG remains acyclic
- [ ] No circular references introduced
- [ ] Schema evolution strategy defined
- [ ] Cross-chain design covers failure modes
- [ ] Security model documented
- [ ] Interface contracts specified
- [ ] Testing strategy outlined

## Review Format
```markdown
## Architecture Review: {ADR/proposal title}

### Assessment: {APPROVE | REVISE | REJECT}

### Gas Feasibility
{Analysis of gas budget compliance}

### Dependency Impact
{Analysis of module DAG changes}

### Security Considerations
{New attack surface or security concerns}

### Recommendations
1. {specific recommendation}

### Conditions for Approval
- {condition if REVISE}
```
