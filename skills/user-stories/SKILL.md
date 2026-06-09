---
name: user-stories
description: "INVEST user story writing, persona definition, and story mapping for Pact Community projects. Story templates and quality criteria for DAO and Ledger Signer."
---
# User Stories

## INVEST Criteria
- **I**ndependent — self-contained, no ordering dependency
- **N**egotiable — details can be discussed
- **V**aluable — delivers user value
- **E**stimable — effort can be assessed
- **S**mall — completable in one sprint
- **T**estable — has verifiable acceptance criteria

## Story Template
```markdown
### US-{NNN}: {Title}
As a **{persona}**,
I want to **{action}**,
So that **{benefit}**.

#### Acceptance Criteria
- [ ] **AC1**: Given {context}, When {action}, Then {result}
- [ ] **AC2**: Given {context}, When {action}, Then {result}

#### Technical Notes
- Gas estimate: {N}
- Modules affected: {list}
- Dependencies: US-{NNN}
```

## Personas
- **Token Holder** — owns DAO tokens, votes, claims dividends
- **Proposal Creator** — creates governance proposals
- **DAO Admin** — manages configuration, deploys upgrades
- **Ledger User** — signs transactions with hardware wallet
- **Developer** — integrates with Pact modules via SDK
