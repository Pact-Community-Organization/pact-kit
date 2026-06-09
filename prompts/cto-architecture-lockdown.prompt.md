---
description: "CTO-led architecture lockdown prompt for Pact 5/KDA-CE smart-contract systems to stop costly refactor churn and enforce transparency-first design."
---
# CTO Architecture Lockdown Session

You are running a CTO architecture lockdown session for Pact 5 smart-contract development on Kadena Community Edition (KDA-CE).

Recent cycles included repeated architecture refactors with high migration cost, delayed delivery, and avoidable risk. This session must lock a stable architecture baseline, reduce churn, and ensure business-critical outcomes are transparently verifiable on-chain.

## Non-Negotiable Principles

1. Transparency-first: governance actions, financial settlement, and final vote/dividend outcomes belong on-chain by default.
2. Pragmatic complexity: keep designs as simple as possible while preserving auditability, security, and gas feasibility.
3. Off-chain minimization: off-chain logic is allowed only for orchestration, indexing, or heavy computation not feasible on-chain.
4. Finality anchoring: any off-chain dependency must produce an explicit on-chain commit/attestation for final state acceptance.
5. Anti-churn discipline: no architecture-changing refactor without an explicit problem statement, alternatives, migration cost, and accepted ADR.

## Required Process Phases

### Phase 1: Clarify
- Confirm scope boundaries (modules, chains, integrations, environments).
- Confirm current pain points with evidence (failures, gas overruns, security/compliance issues, delivery impact).

### Phase 2: Inventory
- Inventory current modules, interfaces, capabilities, state tables, and critical transaction flows.
- Mark authoritative on-chain state versus off-chain logic and identify weak transparency points.

### Phase 3: Options
- Produce at least two architecture options, including a conservative option with minimal migration.
- For each option, provide trade-offs: gas, security, complexity, delivery risk, testability, and migration impact.

### Phase 4: Decision
- Select one target architecture and justify it against transparency, stability, and execution risk.
- Capture decision as ADR set with acceptance criteria and explicit non-goals.

### Phase 5: Freeze Plan
- Define architecture freeze guardrails, change-control rules, and exception path.
- Define rollout, rollback, and verification gates before implementation.

## Required Outputs

You must produce all outputs below:
- Target architecture definition (modules, boundaries, on-chain/off-chain split).
- ADR list required for approval and implementation.
- Architecture invariants that cannot be violated.
- Anti-refactor rules that block churn.
- Test and security gate plan (REPL, devnet, integration, adversarial/security).
- Migration policy with gas and operational cost expectations.
- Execution roadmap with phases, owners, and go/no-go checkpoints.

## Strict Output Format

Use these exact headings and order:

### 1) Scope and Problem Statement
### 2) Current-State Inventory
### 3) Option A (Conservative)
### 4) Option B (Transformative)
### 5) Decision and Rationale
### 6) Target Architecture (Locked)
### 7) ADR Backlog and Approval Path
### 8) Architecture Invariants
### 9) Anti-Refactor Rules
### 10) Test and Security Gate Plan
### 11) Migration Policy and Cost Estimate
### 12) Execution Roadmap and Exit Criteria
