---
description: "Use when reviewing cross-module interactions, adding state, or modifying Pact module interfaces. Prevents integration gaps found in PR #47."
# Cross-Module Integration Rules

## Root Cause (Lesson from PR #47)
Modules reviewed in isolation = silent bugs. Cross-module write path gaps cause phantom exploits and dead config.

## Mandatory Checks

### For Every Module Review
1. For every `with-default-read` or `read` crossing module boundaries, trace the write path
2. For every config parameter, verify the referenced data source exists in the target schema
3. When `with-default-read` provides zero/empty defaults, verify those defaults cannot be exploited

### When Adding Per-Account State
- New state (dividends, vesting, staking) → MUST update ALL balance-changing functions
- Credit/debit functions need correction factors for accumulator patterns

### When Adding Config Fields
- Config fields referencing aggregated data → tracking schema MUST have matching field
- Example: `quorum_voter_count` config → `voter_count` must exist in chain-tally-schema

### Integration Test Requirement
- Cross-module integration tests MANDATORY when modules share state
- Walk full lifecycle: buy → transfer → vote → claim across ALL modules
- Review deploy-order neighbors (N-1, N+1) when modifying module N

## Module-reference (modref) trust & reentrancy

> Canonical traps: [pact-traps.md](pact-traps.md).

A module reference (`modref`) is **untrusted code**. When you call into a modref,
you are invoking an implementation you do not control — and **it runs with every
capability currently in scope**. Treat every modref call as a call into a
potential attacker's contract.

### Privilege escalation — the pattern to AVOID
Acquiring a sensitive capability **before** a modref call lets a malicious
implementor re-enter your own internals that are guarded by
`require-capability`. Classic data-market example: a `BUY` flow holds
`INTERNAL_FUNDS_CAP` in scope, then calls a seller-supplied modref; the modref
re-enters a `require-capability (INTERNAL_FUNDS_CAP)`-guarded `debit` and **drains
funds**, because the cap the internal function demands is *already granted*.

```pact
; VULNERABLE — cap is in scope across the untrusted call
(defun buy (item:object seller:module{seller-iface})
  (with-capability (INTERNAL_FUNDS_CAP)        ; <-- granted BEFORE modref call
    (let ((price (seller::quote item)))        ; modref runs WITH the cap in scope
      (debit buyer price))))                   ; seller can re-enter debit
```

**FIX — resolve modref values first, THEN scope the cap around trusted code only:**

```pact
(defun buy (item:object seller:module{seller-iface})
  (let ((price (seller::quote item)))          ; (1) resolve modref OUTSIDE any cap
    (with-capability (INTERNAL_FUNDS_CAP)      ; (2) cap scopes only trusted code
      (debit buyer price))))                   ; no untrusted call in this scope
```

Rule: **bind all modref results via `let` first; only then open the
`with-capability` around purely-internal, trusted code.** Never hold a sensitive
cap across an external/modref call.

### Cross-function reentrancy (CertiK PoC)
Holding a capability across an external call lets the callee re-enter the **same**
caller function and observe/abuse partial state. Mitigations, in order:
1. **Strong capability predicates** — caps must enforce identity
   (`enforce-guard`), not just compare values.
2. **Never hold a sensitive cap across an external/modref call** (the let-first
   pattern above).
3. **Pact 5.3+ read-only-by-default modref reentrancy** — when a modref re-enters
   the **originating** module, that re-entry is forced **read-only** (DML blocked:
   `Operation disallowed in read-only or sys-only mode`). Present in Pact 5.4ce (KDA-CE).
   Upstream-verified in `pact-tests/pact-tests/reentrancy.repl`: the block holds even
   when the re-entered function's `require-capability` is satisfied — reads succeed,
   any `update`/`write` aborts. **Do not treat it as the sole defense** — keep
   mitigations (1) and (2).

### Late binding — modrefs resolve to the LATEST target
A modref resolves at call time to the **currently deployed (latest upgraded)**
implementation. A trusted target today can be upgraded to malicious code
tomorrow.
- **Prefer a direct module reference** when there is a single known implementor.
- When you must accept a modref, **pin it** — `use module-name hash` ties the
  dependency to a specific code hash.
- Cross-module references still **resolve at load time** and **circular
  dependencies remain forbidden**.
