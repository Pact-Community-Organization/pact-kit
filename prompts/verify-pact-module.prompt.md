---
description: "Tester/Security: Run formal verification and typechecking on a Pact 5 module — verify, typecheck, --check/--check-shadowing — prove conserves-mass and non-negative-balance, document proven vs unsupported properties, and report counterexamples."
---
# Verify a Pact Module (formal verification + typecheck)

> Canonical traps: [../instructions/pact-traps.instructions.md](../instructions/pact-traps.instructions.md)
> Skills: [formal-verification](../skills/formal-verification/SKILL.md), [pact-invariants](../skills/pact-invariants/SKILL.md), [pact-cli-tooling](../skills/pact-cli-tooling/SKILL.md)

## 1. Run the tooling (in order)
```bash
pact --check FILE.pact            # parse + load (no eval)
pact --check-shadowing FILE.pact  # native-name shadowing (load-time error in 5.1+)
```
```pact
(typecheck 'free.my-module)   ; native typechecker (5.2+) — must be clean first
(verify   'free.my-module)    ; Z3: typecheck + @model properties/invariants
```
- `verify` typechecks first, then discharges `@model` clauses. A typecheck failure makes `verify` results meaningless — fix typecheck first.

## 2. Required invariants on fungible tables
- **Conserves mass**: column-delta of the balance column = 0 across every transfer/mint/burn pair that must net to zero — `(property (= (column-delta table 'balance) 0.0))` style.
- **Non-negative balance**: `(invariant (>= balance 0.0))` on the balance schema — no row may go negative.
- Apply these to every table that holds value.

## 3. Properties assume success — scope them
- `@model` properties hold **only on successful execution**. Use `succeeds-when` / `fails-when` to scope guard conditions, otherwise a property is vacuously true on the failure path.
- State, for each property, the success condition it assumes.

## 4. Document proven vs unsupported
- List each property/invariant and its status: **PROVEN**, **COUNTEREXAMPLE**, or **UNSUPPORTED**.
- Note coverage limits: the verifier has **limited support for defpacts** and some higher-order / cross-module constructs — call these out explicitly rather than implying full coverage.

## 5. Counterexamples
- For every failed property, record the concrete counterexample Z3 returns (input values + offending state) and the exact function/line.
- Classify: real defect vs missing precondition (`succeeds-when`/`fails-when`) vs unsupported construct.

## Report
```markdown
## Verification — {module}
--check / --check-shadowing: {PASS | errors}
typecheck: {PASS | errors}
verify: {N proven, N counterexample, N unsupported}

Invariants:
- conserves-mass({table}.balance): [PROVEN | COUNTEREXAMPLE: {…}]
- non-negative-balance({table}.balance): [PROVEN | COUNTEREXAMPLE: {…}]

Unsupported / out-of-scope: {defpact steps, …}
Verdict: [Security] [APPROVE | BLOCK] — {justification}
```
