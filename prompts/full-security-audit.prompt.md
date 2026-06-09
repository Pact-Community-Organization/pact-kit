---
description: "Security: Execute a comprehensive 5-phase security audit of a Pact project — architecture review, code review, capability audit, attack simulation, and report."
---
# Full Security Audit

## 5-Phase Protocol

### Phase 1: Architecture Review
- Module dependency analysis
- Trust boundary identification
- Governance model assessment
- Cross-chain design review

### Phase 2: Code Review
- Line-by-line .pact review
- Pact 5 critical trap check
- Guard verification on all write paths
- Logic correctness verification

### Phase 3: Capability Audit
- Map all capabilities
- Trace composition chains
- Verify @managed scoping
- Check cross-module boundaries

### Phase 4: Attack Simulation
- Design exploits per STRIDE category
- Execute on devnet (port 8083)
- Document all attempts and results
- PoC for any successful exploit

### Phase 5: Report
```markdown
## Security Audit Report — {project}
Date: {date}
Auditor: [Security]

Summary: {N} critical, {N} high, {N} medium, {N} low
Verdict: [Security] [APPROVE | REJECT]

### Findings (by severity)
#### CRITICAL-001: {title}
{Location, description, PoC, recommendation}

### Recommendations
{Prioritized list}
```
