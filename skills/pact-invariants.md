---
name: pact-invariants
description: "Pact formal verification with @model annotations, invariant properties, conservation laws, and property-based testing for smart contract correctness."
---
# Pact Invariants — choosing & writing them

> For the full `@model` grammar (annotation kinds, vocabulary, quantifiers,
> `succeeds-when`/`abort`/`result`, limits) see the `formal-verification` skill.
> Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md).
>
> This skill complements `formal-verification`: it is about **deciding which
> invariants and properties a real module needs**, and where each one lives.

## Where each kind lives

| Want to constrain… | Use | Lives on |
|---|---|---|
| Data shape (a column can never be negative) | `(invariant ...)` | `defschema` |
| A function's behavior (auth, conservation, args, result) | `(property ...)` | `defun` `@model` |
| A reusable predicate | `(defproperty ...)` | module level |

**Schema `(invariant …)`** may reference only the schema's columns — no args, no
auth, no DB-mutation predicates. **`(property …)`** on a defun may use the full
vocabulary (auth, `column-delta`, `row-written`, `abort`, `result`, …).

```pact
(defschema account
  @model [ (invariant (>= balance 0.0)) ]   ; data-shape only
  balance:decimal guard:guard)

(defun transfer:string (from:string to:string amount:decimal)
  @model [ (property (= (column-delta accounts 'balance) 0.0)) ]  ; behavior
  ...)
```

## The invariant catalog (pick what applies)

### 1. Conservation of mass
Total value is preserved across the operation. The workhorse for any token.
```pact
(property (= (column-delta accounts 'balance) 0.0))   ; transfer: no net change
```
For mint/burn the delta equals `+amount` / `-amount`, not zero — be explicit.

### 2. Non-negative balances
No account can go below zero, regardless of code path.
```pact
(defschema account @model [ (invariant (>= balance 0.0)) ] balance:decimal ...)
```

### 3. Monotonic state-machine flags
A boolean/flag may transition in only one direction. Classic: a dividend/redeem
flag goes `false → true` once and never back.
```pact
; redeemed may only flip false->true (never re-credit)
(property (when (row-written claims k)
                (or (= (cell-delta claims 'redeemed k) true)   ; became true
                    (= (cell-delta claims 'redeemed k) false)))) ; unchanged
```
State machines (e.g. proposal `OPEN → VOTING → CLOSED`) should never skip or
reverse — assert the allowed transitions.

### 4. Input validity
Reject nonsense before it touches the DB.
```pact
(property (> amount 0.0))
; plus enforce-unit on every external decimal (precision)
```
Pair the property with a runtime `(enforce-unit amount)` so precision is checked
on-chain, not just in the model.

### 5. Authorization preconditions
Every state mutation traces back to an enforced guard.
```pact
(property (row-enforced accounts 'guard from))   ; the debited row's guard ran
; stronger, all rows:
(property (forall (k:string)
            (when (row-written accounts k)
                  (row-enforced accounts 'guard k))))
```

## Project-specific invariants

### Voting
- `vote_amount <= balance` during VOTING status.
- Sum of votes <= total supply (no double-spend of voting weight).
- Single-use VOTE cap (bare `@managed`) makes replay impossible — assert the vote
  row transitions `unvoted → voted` once.

### Dividend (ADR-002)
- `owed = balance * (pps - last_points) + correction`.
- `last_points` is **monotonically non-decreasing** per account (no double-claim).
- Claiming flips a redeemed flag `false → true` only.

## Workflow
1. Pick invariants from the catalog that match the module's risk surface.
2. Place data-shape ones on the schema, behavioral ones on the defun.
3. **`(verify 'module)` is NOT implemented in Pact 5.4ce** — `@model` is parsed
  but unenforced. Run `(typecheck 'module)` (5.2+) and assert the same properties
  via REPL `expect`/`expect-failure` + devnet adversarial tests.
4. Fix code or refine the property; re-check.
5. Record the asserted set in the module's ADR.

## Property categories (mental model)
- **Safety** — a bad state is never reachable (non-negative balance).
- **Conservation** — a quantity is preserved (column-delta = 0).
- **Monotonicity** — a value only moves one way (last_points, redeemed flag).
- **Authorization** — every mutation was guarded (row-enforced).
