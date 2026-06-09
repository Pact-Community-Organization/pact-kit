---
name: requirements-analysis
description: "Requirements elicitation, analysis, and documentation for Pact Community. Transform user needs into testable specifications, user stories, and acceptance criteria."
---
# Requirements Analysis

## Elicitation Process
1. **Gather** — Understand the user's need (what problem to solve)
2. **Analyze** — Break into functional and non-functional requirements
3. **Specify** — Write testable acceptance criteria
4. **Validate** — Confirm with stakeholder (user or Product agent)

## User Story Format
```
As a [role],
I want to [action],
So that [benefit].

### Acceptance Criteria
Given [context]
When [action]
Then [expected result]
```

## Requirement Classification
- **Functional** — What the system does
- **Non-functional** — How well it does it (gas, security, UX)
- **Constraint** — Limitations (150k gas, Pact 5, KDA-CE platform)
- **Interface** — External system interactions (Ledger, wallets)

## Traceability
- Every requirement → at least one test
- Every test → cites its requirement (ADR, PROC, AC)
- Every feature → links to user story
