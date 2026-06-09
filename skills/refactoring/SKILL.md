---
name: refactoring
description: "Safe refactoring patterns for Pact 5 modules — rename, extract, inline, and restructure while preserving behavior and maintaining cross-module compatibility."
---
# Refactoring Patterns

## Safe Refactoring Protocol
1. **Verify** — All tests pass before starting
2. **Plan** — Document what changes and why
3. **Execute** — Make minimum necessary changes
4. **Verify** — All tests pass after completion
5. **Measure** — Gas impact before and after

## Common Refactorings

### Extract Function
```pact
;; Before: inline logic
(defun transfer (sender receiver amount)
  (enforce (> amount 0.0) "Positive")
  (debit sender amount)
  (credit receiver amount))

;; After: extracted validation
(defun validate-transfer (amount:decimal)
  (enforce (> amount 0.0) "Positive"))

(defun transfer (sender receiver amount)
  (validate-transfer amount)
  (debit sender amount)
  (credit receiver amount))
```

### Rename (Cross-Module)
1. List all modules that `use` the target module
2. Update function name in the source module
3. Update all call sites in dependent modules
4. Update all test files
5. Update deploy scripts and documentation

## Constraints
- Cannot rename tables (would lose data on upgrade)
- Cannot remove schema fields (breaks with-default-read)
- Cannot change function signatures in interfaces
