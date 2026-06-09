---
description: "Product: Define requirements for a new feature — user story, acceptance criteria, priority, and initial scope for Pact Community projects."
---
# Define Requirements

## Process
1. Understand the user's need
2. Write user story (INVEST criteria)
3. Define acceptance criteria (Given/When/Then)
4. Classify priority (MoSCoW)
5. Identify affected modules
6. Estimate effort and gas impact
7. Hand off to Architect

## Output
```markdown
## Requirement: {title}

### User Story
As a **{persona}**,
I want to **{action}**,
So that **{benefit}**.

### Acceptance Criteria
- [ ] AC1: Given {X}, When {Y}, Then {Z}
- [ ] AC2: Given {X}, When {Y}, Then {Z}

### Priority: {Must | Should | Could | Won't}
### Effort: {S | M | L | XL}
### Modules: {affected modules}
### Gas Impact: {estimate}

### Dependencies
- {prior work required}

### Definition of Done
- [ ] ACs met and tested
- [ ] Gate 2 passed
- [ ] Docs updated
- [ ] CHANGELOG entry
```
