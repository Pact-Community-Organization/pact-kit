---
name: pact-repl-testing
description: "Pact REPL test scaffolding, expect/expect-failure patterns, env-data/env-sigs setup, and test-driven development for .repl test files."
---
# Pact REPL Testing

## Test File Structure
```pact
;; ============================================================
;; Setup
;; ============================================================
(begin-tx "Setup environment")
(env-data { "admin-keyset": { "keys": ["admin-key"], "pred": "keys-all" }})
(env-sigs [{ "key": "admin-key", "caps": [] }])
(define-namespace "free" (read-keyset "admin-keyset") (read-keyset "admin-keyset"))
(namespace "free")
(define-keyset "free.admin-keyset" (read-keyset "admin-keyset"))
(load "../modules/my-module.pact")
(commit-tx)

;; ============================================================
;; Tests: ADR-001 — Core functionality
;; ============================================================
(begin-tx "Test: function-name happy path")
(env-sigs [{ "key": "admin-key", "caps": [] }])
(expect "should return expected value"
  expected-value
  (free.my-module.function-name args))
(commit-tx)

(begin-tx "Test: function-name unauthorized")
(env-sigs [])
(expect-failure "Keyset failure"
  (free.my-module.function-name args))
(commit-tx)
```

## Critical Rules
1. `expect-failure` MUST use specific error string — NEVER `""`
2. Each test in its own `begin-tx`/`commit-tx` block
3. Reset state between tests — no implicit dependencies
4. Comment with requirement source: `; Tests: ADR-NNN`
5. Test both authorized AND unauthorized paths
6. `expect-failure` does NOT rollback prior DB writes — clean state before each test
7. **NO cross-chain in the REPL — ever.** SPV is unsupported in the bare REPL, so a
   cross-chain step (`yield` to a target chain, cross-chain `continue-pact`, SPV/continuation
   proofs) CANNOT be tested here — it will fail `SPVVerificationFailure` / not resolve.
   REPL-test only the same-chain scope; push all cross-chain verification to a multi-chain
   devnet. See [testing-rules](../instructions/testing-rules.md) HARD RULE.
