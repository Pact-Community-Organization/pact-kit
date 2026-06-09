---
name: system-architecture
description: "System-level architecture design for KDA-CE Pact 5 smart contracts. ADR creation, module decomposition, cross-chain patterns, and architecture trade-off analysis."
---
# System Architecture

## Architecture Decision Records (ADRs)
Capture every significant design decision:
```
# ADR-{NNN}: {Title}
Status: Proposed | Accepted | Deprecated | Superseded
Date: YYYY-MM-DD
Context: Why this decision is needed
Decision: What was decided
Consequences: Trade-offs accepted
```

## Module Decomposition Criteria
- Single responsibility per module
- Gas budget per module ≤ 150k for deploy
- Clear capability boundary (what each module guards)
- Minimal cross-module writes (prefer read + local compute)

## Architecture Review Checklist
- [ ] Gas budget estimated for all public functions
- [ ] Cross-chain flow designed where needed
- [ ] Module dependency DAG is acyclic
- [ ] Schema evolution strategy (with-default-read for migrations)
- [ ] Failure modes documented
- [ ] Interface contracts defined
