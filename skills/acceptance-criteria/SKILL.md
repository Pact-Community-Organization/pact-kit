---
name: acceptance-criteria
description: "Given/When/Then BDD acceptance criteria writing for Pact 5 features. Testable criteria design, completeness validation, and AC quality checks."
---
# Acceptance Criteria

## Format (Given/When/Then)
```
Given [initial context/state]
When [action/event occurs]
Then [expected outcome is observed]
```

## Quality Rules
- Every AC must be independently testable
- "Given" must be achievable in test environment
- "When" must be a specific action (not vague)
- "Then" must be measurable (not subjective)
- Include both positive and negative ACs

## Examples
```
AC: Token Transfer
Given an account "alice" with 100.0 my-token tokens
When "alice" transfers 50.0 tokens to "bob"
Then "alice" balance is 50.0
And "bob" balance is 50.0
And total supply is unchanged

AC: Unauthorized Transfer (Negative)
Given an account "alice" with 100.0 my-token tokens
When "mallory" attempts to transfer from "alice" without authorization
Then the transaction fails with "Keyset failure"
And "alice" balance remains 100.0
```

## Completeness Checklist
- [ ] Happy path covered
- [ ] Error/failure paths covered
- [ ] Authorization requirements specified
- [ ] Boundary conditions covered
- [ ] Cross-module effects specified
