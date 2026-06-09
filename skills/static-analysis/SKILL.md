---
name: static-analysis
description: "Automated code scanning for Pact 5 — detect critical traps, built-in name collisions, binary operator errors, read-only violations, and common anti-patterns."
---
# Static Analysis

> Canonical traps: [../../instructions/pact-traps.instructions.md](../../instructions/pact-traps.instructions.md). This skill is a Developer **pre-commit** pass: run the real tooling first, then targeted greps for what tooling can't see.

## Two-tier model

**Tier 1 catches more than grep ever will.** Greps are a backstop for *semantic*
anti-patterns the compiler/checker doesn't flag — and greps have false positives
(notably multiline misses). Never ship Tier 2 results as findings without Tier 1.

## Tier 1 — real tooling FIRST (authoritative)

Run these before any grep. They parse and type the module, so they catch
shadowing, arity/parse/type errors, and FV violations *correctly*.

```bash
pact --check FILE.pact            # parse + load check (no eval)
pact --check-shadowing FILE.pact  # native-name shadowing (load-time error in 5.1+)
```

```pact
; in a .repl, against the loaded module:
(typecheck 'my-namespace.my-module)   ; native typechecker (5.2+)
(verify   'my-namespace.my-module)    ; Z3 property checker — typecheck + @model
```

What Tier 1 authoritatively flags:
- Native/built-in **shadowing** (`Variable X shadows native of the same name`).
- **Parse / arity** errors — including `(+ 1 2 3)`
  (`Attempted to apply a closure to too many arguments`).
- **Type** errors.
- **@model / invariant** violations with concrete counterexamples.

If Tier 1 fails, fix that first — Tier 2 greps on a non-loading module are noise.

## Tier 2 — targeted greps (semantic backstop)

> Caveat: `grep` is line-oriented. Multiline constructs (a `try` whose `update`
> is on the next line, a `+` whose third arg wraps) **will be missed**. Treat
> every hit as a *lead to inspect*, not a confirmed defect. Confirm by reading.

### Rule 0 (THE #1 rule) — unguarded state-mutating defun
**Every `insert` / `update` / `write` must be reachable only behind a
`with-capability`, a `require-capability`, or an `enforce-guard`.** For each hit,
walk **up to the enclosing `defun`** and confirm a guard dominates the write.
```bash
grep -rnE '\((insert|update|write)\b' pact-examples/pact/modules/
# For each hit: open the file, find the enclosing defun, verify a
# with-capability / require-capability / enforce-guard gates the write.
```
An internal mutator with **no** guard and **no** leading `require-capability` is a
critical finding (direct-call exploit).

### Read-only / DML-in-try (false-positive-prone)
```bash
grep -rnE '\btry\b' pact-examples/pact/modules/   # then read each: any insert/update/write inside? (multiline-aware by eye)
```
DML inside `try`/`enforce` arg → `Operation disallowed in read-only or sys-only mode`.

### Empty expect-failure (false passes)
```bash
grep -rn 'expect-failure ""' pact-examples/pact/tests/
grep -rnE "expect-failure[[:space:]]+\"\"" pact-examples/pact/tests/
```

### Ternary `+` (binary-only) — note multiline limitation
```bash
grep -rnE '\(\+[[:space:]]+[^()]+[[:space:]]+[^()]+[[:space:]]+[^()]+\)' pact-examples/pact/modules/
# misses (+ a (long\n expr)); confirm by reading
```

### Open governance
```bash
grep -rnE 'defcap[[:space:]]+GOV(ERNANCE)?[[:space:]]*\([[:space:]]*\)[[:space:]]+true' pact-examples/pact/modules/
```
A governance cap whose body is literally `true` = anyone can upgrade the module.

### read-keyset inside a governance defcap
```bash
grep -rnE 'read-keyset' pact-examples/pact/modules/   # confirm none sit inside a GOVERNANCE defcap
```
Reading the governing keyset from tx data lets the upgrader supply their own.

### enforce-guard / enforce-keyset OUTSIDE a defcap (unscoped signature)
```bash
grep -rnE '\b(enforce-guard|enforce-keyset)\b' pact-examples/pact/modules/
# A guard enforced in a plain defun (not wrapped by a defcap) is an UNSCOPED
# signature — it can't be cap-scoped in the signer clist. Prefer guarding via a defcap.
```

### Weak capability predicate
```bash
grep -rnA3 'defcap' pact-examples/pact/modules/
# Flag defcaps whose body only does != / value comparisons and NO enforce-guard /
# enforce-keyset — a cap that checks data but never identity is not access control.
```

### Weak/`true`-body cap acquired on a public path (advisory / WARN)
```bash
# 1) Enumerate every true-body or trivially-weak defcap.
grep -rnE 'defcap[[:space:]]+[A-Za-z0-9_-]+[[:space:]]*\([^)]*\)[[:space:]]+true' pact-examples/pact/modules/
grep -rnA3 'defcap' pact-examples/pact/modules/   # also: bodies doing only != / value comparisons
# 2) For EACH weak cap C, grep its acquisition sites and walk up to a real guard.
grep -rnE '\(with-capability[[:space:]]+\(C\b'    pact-examples/pact/modules/
grep -rnE '\(require-capability[[:space:]]+\(C\b' pact-examples/pact/modules/
```
A weak/`true`-body cap is an **internal permission token**, not authorization —
it is only acquirable inside its declaring module. It is a finding **only** when a
**public** function `with-capability`s it with **no upstream real guard**
(`enforce-guard` / scoped-managed signature / runtime context) between the public
entrypoint and the acquisition (YODA6 / `bad-credit` free-mint). If it is acquired
only **composed under a real-guarded parent** (coin `CREDIT` under `DEBIT`) or only
by runtime/execution context (`GAS`/`COINBASE`), it is **safe** — WARN, not fail.
Use the grep walk-up heuristic in
[../capability-analysis/SKILL.md](../capability-analysis/SKILL.md).

> Governance is the hard case: `(defcap GOVERNANCE () true)` /
> `(defcap GOV () true)` on an **upgradeable** module is a hard finding (anyone
> seizes module admin — `true`=catastrophic). `(enforce false "...")` is the
> **correct immutability sentinel** (deny-all ⇒ un-acquirable ⇒ non-upgradeable).
> The existing **Open governance** grep above catches the `true` form.

### select / keys on a transactional path
```bash
grep -rnE '\b(select|keys|fold-db)\b' pact-examples/pact/modules/
# These are unbounded table scans. Allowed only on /local read paths, never in a
# function that runs on-chain in a real tx (gas + non-determinism risk).
```

### Deprecated guard constructors
```bash
grep -rnE 'create-(module|pact)-guard' pact-examples/pact/modules/
# module guards and pact guards are DEPRECATED as unsafe. Use keyset / cap / user guards.
```

### pact-id used as authorization
```bash
grep -rnE 'pact-id' pact-examples/pact/modules/
# (pact-id) throws outside a defpact and proves no identity inside one.
# Never gate access on pact-id — use a composed capability bound to identity.
```

## Pre-commit checklist (Developer)
1. `pact --check` + `pact --check-shadowing` clean on every changed `.pact`.
2. `(typecheck …)` and `(verify …)` clean on changed modules.
3. Tier 2 greps run; every hit read and dispositioned.
4. Rule 0 confirmed for **every** insert/update/write touched in the diff.
