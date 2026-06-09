---
description: "Use when evaluating quality gates, determining merge readiness, or making go/no-go decisions. Defines the Three-Gate Model for Pact Community with pass/fail criteria."
# Quality Gate Rules — Three-Gate Model

## Gate 1 — Pre-Code

**Purpose**: Requirements and architecture approved before coding begins.

**Flow**: Product → Architect → Developer

**Pass Criteria**:
- [ ] User story meets INVEST criteria
- [ ] Acceptance criteria are testable (Given/When/Then)
- [ ] ADR approved (if architectural change)
- [ ] Gas budget estimated and within 150k ceiling
- [ ] Module dependency impact assessed
- [ ] No open blockers from prior milestones

**Fail → Returns to**: Product (requirements) or Architect (design)

## Gate 2 — Pre-Merge

**Purpose**: Code quality verified before merge to main branch.

**Flow**: Developer → Tester + Security → Orchestrator

**Pass Criteria**:
- [ ] REPL tests pass (all `expect` / `expect-failure`)
- [ ] Devnet deploy succeeds on dedicated port
- [ ] Unit tests pass (vitest for TypeScript)
- [ ] Integration tests pass (cross-module lifecycle)
- [ ] Tester verdict: `[GO]` with justification
- [ ] Security verdict: `[APPROVE]` (no CRITICAL/HIGH findings)
- [ ] No unresolved `[UNCERTAIN]` findings
- [ ] Code review comments addressed

**Tester Veto**: Any `[NO-GO]` blocks merge until resolved.
**Security Veto**: Any `[CRITICAL]` finding blocks merge.

**Fail → Returns to**: Developer (fix) or Architect (redesign)

## Gate 3 — Pre-Deploy

**Purpose**: Production readiness confirmed before deployment.

**Flow**: Tester GO + Security APPROVE → DevOps → Orchestrator

**Pass Criteria**:
- [ ] Gate 2 passed
- [ ] Testnet deployment succeeds
- [ ] Gas measurements within budget on testnet
- [ ] CHANGELOG updated
- [ ] API documentation updated
- [ ] Deployment runbook prepared
- [ ] Rollback plan documented (where applicable)

**Fail → Returns to**: DevOps (infrastructure) or Developer (fixes)

## Decision Format
```
[AgentName] [GO|NO-GO|APPROVE|REJECT]
Justification: {evidence-based reasoning}
Conditions: {any conditions on the decision}
Findings: {reference to detailed findings}
```
