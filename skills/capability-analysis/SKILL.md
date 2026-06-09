---
name: capability-analysis
description: "Deep analysis of Pact 5 capability guards — verify capability composition, managed capabilities, install-capability scoping, and guard enforcement patterns."
---
# Capability Analysis

## Audit Checklist

### For Every Module
- [ ] List all defined capabilities (defcap)
- [ ] Map which functions use which capabilities
- [ ] Verify no public write function lacks capability guard
- [ ] Check GOVERNANCE cap guards all admin functions

### For Every @managed Capability
- [ ] Manager function correctly tracks allowance
- [ ] install-capability is inside with-capability
- [ ] Managed amount decreases correctly
- [ ] Cannot exceed initial allowance
- [ ] Handles edge cases (zero, exact amount, slightly over)

### For Every compose-capability
- [ ] Composition chain is correct
- [ ] No transitive bypass possible
- [ ] All composed caps reach proper enforce-guard

### Cross-Module Capabilities
- [ ] Capabilities don't leak across module boundaries
- [ ] Cross-module calls don't inherit caller's capabilities
- [ ] Each module re-grants needed capabilities independently

## Capability Map Template
```
Module: {name}
├── GOVERNANCE → enforce-guard(keyset-ref-guard)
├── ADMIN → compose(GOVERNANCE)
├── TRANSFER → @managed amount → compose(DEBIT) + compose(CREDIT)
│   ├── DEBIT → enforce-guard(account guard)
│   └── CREDIT → (auto-granted)
└── EVENT → @event
```

## Auditing weak/`true`-body capabilities

A `defcap` body is an **internal gate, not a public ACL**. A cap is acquirable
only inside its declaring module (external `with-capability` fails
`Module admin necessary for operation but has not been acquired`). So a
`true`/weak-body cap is an **in-module permission token** — security lives at the
**acquisition site**, not in the body.

### SAFE-vs-EXPLOITABLE rule

A weak-body (`true` or trivial-`enforce`) capability `C` is **SAFE iff ALL** hold:

1. **No direct public exposure.** No public `defun`/`defpact` step does
   `(with-capability (C ...) ...)` where `C` is the outermost/sole gate and its
   body does no real authorization.
2. **Private consumers.** Every function performing the privileged effect begins
   with `(require-capability (C ...))` and is never wrapped by a public function
   that acquires `C` without a preceding real guard.
3. **Real guard upstream.** The acquisition path that brings `C` into scope passes
   ≥1 **real** check: `enforce-guard` of a stored/account guard, a scoped/managed
   signature, or an unforgeable runtime context / capability guard.
4. **Structural invariant.** Value-creating `C` is paired with a conserving
   counterpart (coin `CREDIT` always follows `DEBIT`) and ideally backed by a
   `@model` conservation property.
5. **`@managed` where one-shot/budgeted.** If it must run once or within a budget,
   `C` (or its parent) is `@managed` so a signature is mandatory and replay within
   the tx is blocked.
6. **No leakage across modrefs.** `C` is not left in scope when calling external
   modules.

**EXPLOITABLE if ANY** of: a public function acquires `C` as the sole gate
(YODA6 `USER`); `C` is the governance body and the module is upgradeable
(`(defcap GOV () true)`); a public wrapper acquires `C` before any real guard
(`bad-credit` free-mint); its parent cap lacks a real guard; or `C` leaks across
a modref call.

### Fast grep heuristic

Grep every `(with-capability (C` and every `(require-capability (C`. For each
`with-capability` site, walk **UP** to the nearest enclosing real guard
(`enforce-guard` / scoped-managed signature / runtime context). A
`with-capability (C ...)` on a **public path with no real guard between the
entrypoint and the acquisition** is a finding. If `C`'s body is weak AND it is
acquired only under a real-guarded parent (or only by runtime context), it is safe.

### Magic / execution-context caps (`GAS`, `COINBASE`, `GENESIS`)

Their bodies are `true` because they are **never acquired by ordinary contract
code** — the node's transaction-execution machinery installs them only on
specific protocol paths (`buy-gas`/`redeem-gas`, miner reward, genesis), and the
guarded functions consume them via `require-capability (GAS)` etc. An ordinary tx
can never put them in scope, so "is the cap in scope?" is a reliable proxy for "am
I the node's execution path?" — presence of the cap *is* the proof of context.
A `true` body is justified **only** under this exact condition.

### Marmalade capability-guard escrow (the same pattern, twisted)

`(defcap SALE_PRIVATE:bool (sale-id) true)` has a `true` body, yet the escrow
account is `(create-principal (create-capability-pact-guard (SALE_PRIVATE
(pact-id))))`. Only the sale defpact's own steps can put `SALE_PRIVATE (pact-id)`
into scope, so only it can debit the escrow. Weak body + unforgeable acquisition
context = secure. (Marmalade `CREDIT` is literally `(defcap CREDIT (id receiver)
true)` — safe for the same reasons: private via `require-capability`, paired with
`DEBIT`.)
