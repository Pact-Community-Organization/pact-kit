---
name: quality-gate-enforcement
description: "Verify quality gate pass/fail criteria at each stage of the Three-Gate Model. Ensure all prerequisites met before proceeding to next phase."
---
# Quality Gate Enforcement

## Gate 1 — Pre-Code
**Verifier**: Orchestrator
**Inputs**: Product requirements, Architect design

### Pass Criteria
- [ ] User story meets INVEST criteria
- [ ] Acceptance criteria testable (Given/When/Then)
- [ ] ADR approved (if architectural change)
- [ ] Gas budget estimated within 150k ceiling
- [ ] Module dependency impact assessed

### On Pass → Notify Developer to begin implementation

## Gate 2 — Pre-Merge
**Verifier**: Orchestrator
**Inputs**: Tester report, Security report

### Pass Criteria
- [ ] Tester verdict: `[GO]`
- [ ] Security verdict: `[APPROVE]`
- [ ] No CRITICAL or HIGH findings open
- [ ] All `[UNCERTAIN]` findings resolved or accepted
- [ ] REPL + devnet tests pass

### On Pass → Approve merge, notify DevOps for deploy

## Gate 3 — Pre-Deploy
**Verifier**: Orchestrator
**Inputs**: DevOps readiness, Gate 2 results

### Pass Criteria
- [ ] Gate 2 passed
- [ ] Testnet deployment succeeds
- [ ] Gas within budget on testnet
- [ ] CHANGELOG updated
- [ ] API docs updated

### On Pass → Authorize deployment
