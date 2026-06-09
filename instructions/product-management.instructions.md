---
description: "Use when managing product backlog, writing user stories, prioritizing features, or defining acceptance criteria for Pact Community projects (DAO, Ledger Signer)."
# Product Management Rules

## User Story Format (INVEST)
```
As a [role],
I want to [action],
So that [benefit].

### Acceptance Criteria
Given [context]
When [action]
Then [expected result]
```

## Prioritization: MoSCoW + Value/Effort
- **Must**: Core functionality, security-critical, blocks other work
- **Should**: Important but not blocking, workarounds exist
- **Could**: Nice-to-have, improves UX/DX
- **Won't**: Out of scope for current milestone

## Definition of Done
- [ ] Acceptance criteria met and tested
- [ ] Gate 2 passed (Tester GO + Security APPROVE)
- [ ] Documentation updated
- [ ] CHANGELOG entry added
- [ ] No CRITICAL or HIGH findings open

## Milestone Planning
- Break milestones into 2-week sprints
- Each sprint has clear deliverables with testable outcomes
- Track: planned vs actual gas consumption per module
