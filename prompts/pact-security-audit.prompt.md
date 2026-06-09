---
description: "Developer/Security: Run a security-focused code review on a Pact module. Check capabilities, guards, write paths, and critical traps."
---
# Pact Security Audit

## Audit Scope
- Module: {path to .pact file}
- Focus: capabilities, guards, write paths, traps

## Checklist
### Capability Guards
- [ ] Every write function has capability check
- [ ] GOVERNANCE guards all admin operations
- [ ] @managed caps properly scoped
- [ ] No capabilities pre-granted before cross-module calls

### Data Safety
- [ ] No unguarded table writes
- [ ] with-default-read defaults are safe
- [ ] No sensitive data in error messages
- [ ] Key derivation is collision-free

### Pact 5 Traps
- [ ] No DML inside try blocks
- [ ] enforce boolean arg not reading DB inline
- [ ] Binary + operator only
- [ ] No built-in name collisions
- [ ] with-default-read has all schema fields
- [ ] install-capability inside with-capability
- [ ] Defpact steps have one expression each

## Output
```markdown
## Security Audit: {module}
Findings: {N} critical, {N} high, {N} medium, {N} low
Verdict: {APPROVE | NEEDS-FIX}
{Detailed findings with location, severity, evidence}
```
