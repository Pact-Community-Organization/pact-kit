---
name: incident-response
description: "Security incident handling for Pact 5 smart contracts on KDA-CE. Response protocol, impact assessment, module freeze procedures, and post-incident review."
---
# Incident Response

## Severity Levels
| Level | Description | Response Time | Actions |
|-------|-------------|---------------|---------|
| P0 | Active fund loss | Immediate | Freeze module, emergency patch |
| P1 | Exploitable vulnerability | < 1 hour | Assess impact, prepare fix |
| P2 | Potential vulnerability | < 24 hours | Analyze, plan mitigation |
| P3 | Theoretical risk | < 1 week | Document, plan hardening |

## Response Protocol

### Phase 1: Contain
- Identify affected module(s)
- Assess: is the vulnerability being actively exploited?
- If active: can we freeze the module? (governance keyset)
- Notify Orchestrator immediately

### Phase 2: Analyze
- Root cause analysis
- Impact assessment (what was/could be affected)
- Determine scope (single module or cross-module)
- Document timeline of events

### Phase 3: Fix
- Develop fix (Developer, reviewed by Security)
- Test fix on devnet (port 8083)
- Security re-audit the fix
- Emergency deploy (bypass normal gates if P0/P1)

### Phase 4: Review
- Post-incident report
- Lessons learned
- Process improvements
- Update threat model

## Module Freeze
On KDA-CE, modules can be "frozen" by:
1. Upgrading with all functions enforcing a "frozen" flag
2. Or rotating governance keyset to a cold/multisig keyset
