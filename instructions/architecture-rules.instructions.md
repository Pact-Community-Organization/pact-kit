---
description: "Use when designing system architecture, creating ADRs, reviewing module structure, planning cross-chain flows, or evaluating architectural decisions for Pact 5 / KDA-CE. Architecture review checklist and design principles."
# Architecture Rules

## Seven-Question Framework

Before any architecture decision, answer:
1. **Gas**: Will this exceed the 150,000 gas ceiling per transaction?
2. **Cross-chain**: Does this require defpact/SPV/continuations?
3. **Module order**: Does this create circular dependencies?
4. **Testability**: Can this be tested in REPL AND devnet?
5. **Failure modes**: What happens when this fails mid-execution?
6. **On-chain auditability**: What exact state/events become immutable evidence on-chain, what remains off-chain, and why?
7. **Churn risk**: How does this decision reduce future refactors and avoid repeated migration cost?

## Transparency-First Decision Rule

- Default to on-chain persistence for governance, financial settlement, and final vote/dividend outcomes.
- Off-chain is allowed only for orchestration, indexing, or heavy computation not feasible on-chain.
- Any off-chain dependency must include an on-chain commit or attestation step for finality.
- Document why the chosen split balances transparency and implementation complexity.

## Architecture Freeze Protocol (Smart Contracts)

Before implementation, verify:
- [ ] Explicit problem statement with measurable failure impact
- [ ] At least two alternatives with trade-offs
- [ ] Migration cost estimate (gas + operational)
- [ ] Acceptance criteria and rollback plan
- [ ] ADR accepted before implementation starts

## Kadena Architecture Principles

- Hub-and-spoke: Chain 0 = hub, Chains 1–19 = satellites
- Module deploy order matters — no forward references
- Table creation must be in same tx as module deploy
- Large modules (>3000 lines) may exceed 150k gas — plan split-deploy
- Cross-module references resolve at load time — plan dependency DAG explicitly

## ADR Format

```
# ADR-{NNN}: {Title}
Status: Proposed | Accepted | Deprecated | Superseded
Date: {YYYY-MM-DD}
Context: {Why this decision is needed}
Decision: {What we decided}
Consequences: {Trade-offs and implications}
```

## Module Design Checklist

- [ ] Governance keyset defined and enforced
- [ ] All admin functions guarded by GOVERNANCE capability
- [ ] Gas budget estimated per public function
- [ ] Module dependency order documented
- [ ] Schema evolution strategy defined (with-default-read)
- [ ] Cross-chain flow designed if applicable
- [ ] Interface compliance verified (fungible-v2, etc.)
