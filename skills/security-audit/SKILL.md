---
name: security-audit
description: "Comprehensive security audit methodology for Pact 5 smart contracts. 5-phase audit protocol, finding classification, and audit report generation."
---
# Security Audit

## 5-Phase Audit Protocol

### Phase 1: Architecture Review
- Review module dependency DAG
- Identify trust boundaries
- Map capability hierarchy
- Check governance model

### Phase 2: Code Review
- Line-by-line review of all .pact files
- Check for Pact 5 critical traps
- Verify all write paths are guarded
- Check all enforce conditions

### Phase 3: Capability Audit
- Map all capabilities and their guards
- Verify composition chains
- Check @managed cap scoping
- Test grant/revoke paths

### Phase 4: Attack Simulation
- Design exploit attempts for each STRIDE category
- Test on dedicated devnet (port 8083)
- Attempt every identified attack vector
- Document results (success = CRITICAL finding)

### Phase 5: Report Generation
```markdown
## Security Audit Report — {module/project}
Date: YYYY-MM-DD
Auditor: [Security]

### Summary
Findings: {N critical, N high, N medium, N low}
Verdict: [Security] [APPROVE|REJECT]

### Findings
#### {SEVERITY}-{NNN}: {Title}
Category: {STRIDE category}
Location: {file:line}
Description: {what's wrong}
Impact: {what could happen}
Proof: {evidence or PoC}
Recommendation: {how to fix}
Status: {Open|Fixed|Accepted}
```
