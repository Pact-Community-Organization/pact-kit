---
description: "Use when writing/reviewing Pact 5 code in *.pact/*.repl files for KDA-CE. Covers critical language traps, patterns, and mandatory conventions."
applyTo: "**/*.{pact,repl}"
---
# Pact 5 Language Rules

## Critical Traps

**Full canonical traps + the dual REPL/on-chain error-string table are an ON-DEMAND, sectioned reference: [pact-traps.md](pact-traps.md). It is NOT auto-loaded — open it and read ONLY the section your task touches (it has a Section index at the top). Do not work from memory for error strings.**

Pull the matching `pact-traps` section when your task touches:
- capabilities/events → `Capabilities` · numbers/decimals → `Arithmetic` · tx input (`read-*`) → `Message Data — read-*` · tables → `Database`
- lists/strings/objects (`take`/`drop`/`at`/`enumerate`/`format`) → `List / String / Object natives` · `map`/`filter`/`fold`/`zip`/`bind` → `Higher-order list natives`
- time/deadlines → `Time` · accounts/principals → `Principals` · `chain-data`/`tx-hash` → `Environment` · `if`/`enforce-one` → `Control flow`
- hashing/crypto/ZK → `Hashing / crypto / ZK` · defpacts/cross-chain → `Defpacts` + `Source-Anchored Defpact Traps` · guards/keysets → `Guards` · `.repl` test error substrings → `Reusable error strings`

Most-violated corrections (read the canonical file for the full list + error strings):

- **`enforce` / `try`**: no DML inside the boolean arg / block — **reads ARE allowed**. Binding reads to a `let` is style/gas, not correctness.
- **`with-default-read`**: the default object must contain every field you **BIND**, not every schema field.
- **Native name shadowing** (`exp`, `abs`, `log`, `mod`, `round`, `ln`, `sqrt`, `floor`, `ceiling`, …): **load-time rejected** in Pact 5.1+ — `Variable X shadows native with the same name` (`pact/Pact/Core/Errors.hs :: instance Pretty DesugarError :: InvalidNativeShadowing`).
- **`pact-id`**: `(pact-id)` **throws outside a defpact** and proves nothing about identity inside one — gate with composed capabilities bound to identity.

Defpact-specific source-backed rules:

- Lifecycle is `exec` (step 0) then continuation progression (`cont`) using
  persisted pact state (id/step/rollback/proof), not new Pact code in the
  continuation command payload.
- Evaluator continuation checks are hard invariants (step/id/rollback/state);
  common typed failures include `DefPactStepMismatch`,
  `DefPactRollbackMismatch`, `DefPactIdMismatch`, and
  `DefPactAlreadyCompleted` when continuation state is inconsistent.
- Cross-chain continuation state is validated before resume
  (`CCDefPactContinuationError`), so you must not mutate continuation payload
  assumptions off-chain.
- Nested defpacts are constrained by parent/child progression invariants
  (`NestedDefPactParentStepCountMismatch`,
  `NestedDefPactParentRollbackMismatch`, `NestedDefpactsNotAdvanced`, etc.).
- Rollback mode is only legal at `step-with-rollback` boundaries and terminal
  rollback attempts are rejected by continuation checks.
- `continue-pact` is REPL-only workflow support; do not use it as if it were an
  on-chain module primitive.
- Parser legacy `step` entity forms may parse in compatibility paths, but Pact
  5 desugaring/eval reject entity usage in defpacts
  (`EntityNotAllowedInDefPact`).

## Capability Security Pattern
```pact
(defcap GOVERNANCE ()
  (enforce-guard (keyset-ref-guard "my-keyset")))

(defcap ADMIN ()
  (compose-capability (GOVERNANCE)))

(defun admin-only-function ()
  (with-capability (ADMIN)
    ; privileged code here
  ))
```

## Error Matching Discipline
- In `.repl` tests, `expect-failure` substring matching uses REPL `Pretty` rendering (`renderCompactText` over `PactError`) via `coreExpectFailure` in `pact-repl/Pact/Core/IR/Eval/Direct/ReplBuiltin.hs`.
- On-chain/devnet error text comes from `pactErrorToOnChainError` and bounded text renderers (`pactErrorToBoundedText` / `*ToBoundedText`) in `pact/Pact/Core/Errors.hs`.
- These renderer paths can produce different strings; choose failure substrings from the surface you are actually asserting.
- For canonical substrings, use `pact-traps.md` as the single source.

## Testing Conventions (.repl)
- Use `env-data` and `env-sigs` before each transaction
- Reset state between tests: don't rely on prior test state
- Use specific REPL/Pretty error substrings in `expect-failure`, never `""`; do not copy on-chain BoundedText strings into `.repl` tests.
- Test both positive (authorized) and negative (unauthorized) paths
- Comment each test block with the requirement it validates

## Module Structure
```pact
(namespace "free")
(module my-module GOVERNANCE
  @doc "Module description"

  ; 1. Schema definitions
  ; 2. Table declarations
  ; 3. Capabilities
  ; 4. Core functions
  ; 5. Admin functions
  ; 6. Utility functions
)
(create-table my-table)
```

## Naming Conventions
- Modules: `kebab-case` (e.g., `my-token`)
- Functions: `kebab-case` (e.g., `get-balance`)
- Capabilities: `UPPER-CASE` (e.g., `TRANSFER`, `GOVERNANCE`)
- Tables: `kebab-case-table` (e.g., `account-table`)
- Schema: `kebab-case-schema` (e.g., `account-schema`)
