---
description: "Developer: Generate REPL test suite (.repl) for a Pact module from acceptance criteria and ADR specifications."
---
# Generate REPL Tests

## Input
- Module path (.pact file)
- Acceptance criteria or ADR
- Required test scenarios

## Rules
1. Expected values from SPECIFICATION, not code
2. Every `expect-failure` uses specific error string
3. Every positive test has paired negative (auth) test
4. Each test in own `begin-tx`/`commit-tx` block
5. No implicit state dependencies between tests
6. Every test block cites requirement: `; Tests: ADR-NNN / AC-NNN`

## Output Structure
```pact
;; ==== Setup ====
(begin-tx "Setup: environment and module")
;; Load module, define keysets
(commit-tx)

;; ==== Tests: ADR-NNN ====
(begin-tx "Test: {function} happy path — AC-1")
;; Given: setup
;; When: call function
;; Then: expect result
(commit-tx)

(begin-tx "Test: {function} unauthorized — AC-1 negative")
;; Given: no signer
;; When: call function
;; Then: expect-failure with specific error
(commit-tx)
```
