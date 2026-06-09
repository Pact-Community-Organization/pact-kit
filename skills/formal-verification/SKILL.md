---
name: formal-verification
description: "Pact formal verification — @model properties, property-based testing, conservation proofs, invariant verification, and counterexample analysis."
---
# Formal Verification

> Canonical traps: [../../instructions/pact-traps.instructions.md](../../instructions/pact-traps.instructions.md). For *choosing which* invariants/properties to write per module, see the `pact-invariants` skill — this skill is the grammar reference.

Pact ships a **Z3-backed property checker**. `(verify 'module-name)` first
**typechecks** the module, then discharges every `@model` invariant and property
to the SMT solver. A property holds only if Z3 finds **no counterexample**.

## Three annotation kinds

### 1. `@model [(property ...)]` on a `defun`
Reasons about a single function: its **arguments**, **result**, **DB
reads/writes**, **authorization**, and **success/abort** behavior.

```pact
(defun transfer:string (from:string to:string amount:decimal)
  @model [
    (property (> amount 0.0))
    (property (!= from to))
    (property (= (column-delta accounts 'balance) 0.0))   ; conservation
    (property (row-enforced accounts 'guard from))        ; auth
  ]
  ...)
```

### 2. `@model [(invariant ...)]` on a `defschema`
Constrains **data shape only** — it may reference the schema's own columns and
nothing else. **No auth, no DB-mutation predicates, no function arguments.**
Invariants are checked **inductively**: assumed true before each function, proven
to still hold after.

```pact
(defschema account
  @model [ (invariant (>= balance 0.0)) ]
  balance:decimal
  guard:guard)
```

### 3. Module-level `(defproperty name ...)` — reusable
Define once, reference by name in many functions.

```pact
(defproperty conserves-mass ()
  (= (column-delta accounts 'balance) 0.0))
```

## Properties ASSUME success by default

By default a `property` is checked **only on the success path** — all `enforce`
preconditions are **assumed true**. To make claims that do *not* assume success,
use the propositional forms:

- `(succeeds-when (cond))` / `(fails-when (cond))` — the function succeeds/aborts
  iff the condition holds.
- `abort` / `success` — booleans for the two execution outcomes.
- `result` — the function's return value.

```pact
@model [
  (property (succeeds-when (>= (at 'balance (read accounts from)) amount)))
  (property (fails-when (< amount 0.0)))
  (property (when abort (= (column-delta accounts 'balance) 0.0)))
]
```

## Canonical conservation suite

```pact
; module-level reusable property
(defproperty conserves-mass ()
  (= (column-delta accounts 'balance) 0.0))

; schema invariant — non-negative balance
(defschema account
  @model [ (invariant (>= balance 0.0)) ]
  balance:decimal guard:guard)

; on transfer
(defun transfer:string (from:string to:string amount:decimal)
  @model [
    (property (conserves-mass))
    (property (> amount 0.0))
    (property (row-enforced accounts 'guard from))
  ]
  ...)
```

### Three bugs this suite catches
1. **Negative amount** — `(property (> amount 0.0))` fails; Z3 returns
   `amount = -k` as the counterexample (debit/credit with negative drains).
2. **Money creation when `from == to`** — a single-account double-update
   (debit then credit the same row) breaks `column-delta = 0`; the checker
   finds `from = to`.
3. **Authorization bypass** — drop `enforce-guard` and
   `(row-enforced accounts 'guard from)` fails: a write occurred to a row whose
   guard was never enforced.

## Property vocabulary

### Database
- `(table-written t)` / `(table-read t)`
- `(column-written t c)` / `(column-read t c)`
- `(row-written t r)` / `(row-read t r)`
- `(column-delta t c)` — net change across all rows in column `c`.
- `(cell-delta t c r)` — net change of one cell.
- `(row-exists t r {"before"|"after"})` — existence pre/post tx.
- `(row-read-count t r)` / `(row-write-count t r)`.

### Authorization
- `(authorized-by 'keyset-name)` — that keyset was enforced.
- `(row-enforced t c r)` — the guard in column `c` of row `r` was enforced.
- `(is-principal s)` / `(typeof-principal s)` — principal validity / prefix.
- `(governance-passes)` — module governance was satisfied.

### Transaction outcome
- `abort` / `success` — execution outcome booleans.
- `result` — return value.

### Quantifiers (properties only; operands must be type-annotated)
- `(forall (x:type) body)` / `(exists (x:type) body)`
- `(column-of t c)` — the domain to quantify a column over.

```pact
(property
  (forall (k:string)
    (when (row-written accounts k)
          (row-enforced accounts 'guard k))))   ; every written row was authorized
```

## Limits — `@model` is ONE layer, not a proof of the whole system

- **Defpacts have limited FV support.** coin's `fund-tx` carries the comment
  *"conserves-mass not supported yet"* — multi-step continuations are not fully
  analyzable.
- **Governance-cap bodies are not analyzed for DB reasoning** — don't expect the
  checker to reason through governance side effects.
- **Very-high-precision decimals can invalidate models** — extreme precision can
  make Z3 unable to discharge or produce spurious results.
- **Absence of a counterexample ≠ full proof** — it means Z3 found none within
  the modeled scope. Treat `@model` as one layer alongside REPL + devnet tests.

## Recommended baseline (wire into CI)
- Put `conserves-mass` (`column-delta = 0`) **and** non-negative-balance
  `(invariant (>= balance 0.0))` on **every fungible table**.
- Run `(verify 'module)` in CI — Pact 5.1+ exits non-zero on failure.

## When verification fails
1. Read the counterexample (Z3 gives concrete values).
2. Decide: real bug, or overly strict property?
3. Real bug → document as a finding, fix the code.
4. Property too strict → refine and re-verify.
5. Record verified properties / outcome in the relevant ADR.
