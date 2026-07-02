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
8. **A REPL pass is NOT evidence for the reads-inside-enforce class** — the KDA-CE node
   rejects table reads in `enforce` conditions that the REPL accepts. Devnet only.
   See [pact-traps](../instructions/pact-traps.md) "Read-only context".

## File Header Conventions (community standard — pact-util-lib style)
```pact
(enforce-pact-version "5.3")            ; pin the interpreter the suite is written against
```
After the load transaction, typecheck and print the module hash (release notes / bless lists):
```pact
(typecheck "free.my-module")
(print (format "my-module hash: {}" [(at 'hash (describe-module "free.my-module"))]))
```

## Testing Managed Capabilities (install-before-body semantics)
Pact 5 checks the managed-cap INSTALL **before** evaluating the cap body:
- With no cap-scoped signature, `with-capability` on a managed cap fails
  `Managed capability not installed` — the body's validation never runs.
- To test cap-body validation paths (self-transfer, negative amount, …), each case
  needs a signature scoped to that exact cap shape:
  `(env-sigs [{ "key": k, "caps": [(free.m.TRANSFER "k:send…" "k:recv…" 5.0)] }])`
- Re-installing the same cap token (same non-managed args) within one tx fails
  `Capability already installed` — put each shape in its own `begin-tx`.
- Spend-down is testable: sign for 5.0, transfer 3.0 (passes), transfer 3.0 again
  (`TRANSFER exceeded` from the manager fn). `@managed`/`@event` caps auto-emit —
  assert with `(env-events true)` (returns AND clears the log).

## Composed Predicates (`expect-that`)
```pact
(expect-that "one TRANSFER event" (compose (length) (= 1)) (env-events true))
(expect-that "orderbook has 13 asks" (compose (length) (= 13)) (get-orderbook true NIL 50))
```
Partial application of natives (`(= 1)`, `(length)`) composes into reusable predicates
— the standard assertion style across CryptoPascal31 / brothers-DAO suites.

## Stub Modules for Cross-Module Dependencies
When the module under test calls another module (oracle, token), load a minimal stub
implementing the same interface from `tests/stubs/` (brothers-DAO pattern —
`bro-dex/tests/stubs/abc.pact`, `bro-lottery/tests/stubs/btc-oracle.pact`). The stub
returns canned values; the real dependency is exercised on devnet.

## Integration-Style Suites: kadena_repl_sandbox
For tests that need real `coin`, namespaces, `free.util-lib`, or marmalade preloaded,
use CryptoPascal31's [kadena_repl_sandbox](https://github.com/CryptoPascal31/kadena_repl_sandbox):
vendor its `kda-env/` and `(load "kda-env/init.repl")` first — it bootstraps guards,
namespaces, kadena base contracts, and funded test accounts (feature-toggled via
`env-data` keys like `disable-marmalade`). This is the community-standard REPL
environment (used by brothers-DAO and daplcor projects).

## Living Reference
A complete suite demonstrating all of the above ships with the kit:
[examples/example-token.repl](../examples/example-token.repl) (run `pact examples/example-token.repl`).
