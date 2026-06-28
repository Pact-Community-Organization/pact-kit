---
name: pact-security-review
description: "Developer-level security review for Pact 5: capability audit, guard verification, unguarded writes, common vulnerabilities."
---
# Developer Security Review

> Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md)

## Pre-Commit Security Checklist

### Capability Verification
- [ ] Every write function has appropriate capability guard
- [ ] `GOVERNANCE` cap protects all admin functions
- [ ] `@managed` caps have correct manager functions
- [ ] No capabilities granted before cross-module calls
- [ ] Guard functions use `enforce-guard`, not manual key checks

### Data Access
- [ ] No unguarded table writes
- [ ] `with-default-read` defaults are safe (non-exploitable)
- [ ] Read functions don't leak sensitive data
- [ ] Key derivation is deterministic and collision-free

### Logic Safety
- [ ] No DML inside `try` blocks
- [ ] No DML (insert/update/write) inside `enforce` args or `try` — DB **reads are allowed** (binding a read to a `let` is style/gas only, NOT a correctness requirement)
- [ ] `+` operator used as binary only
- [ ] No built-in name shadowing (exp, abs, log, etc.)
- [ ] Defpact steps have exactly one expression each

### Edge Cases
- [ ] Zero amount transfers handled
- [ ] Self-transfers handled
- [ ] Account doesn't exist yet (first credit) handled
- [ ] Maximum values tested (near integer/decimal limits)

## Weak/`true`-body capability exposed on a public path = free-mint finding

**Check:** A public `with-capability` of a weak/`true`-body cap with **no upstream
real guard** is a free-mint / privilege-escalation finding.

A cap body is an *internal gate*, not a public ACL — it can only be acquired
inside its declaring module. So a `true`/weak body is an in-module permission
token; the danger is **exposing its acquisition through an unguarded public
function**, not the weak body itself.

```pact
; ANTI-PATTERN (VERIFIED free-mint) — public defun acquires the weak cap directly.
(defcap CREDIT (acct:string) (enforce (!= acct "") "valid"))   ; weak body
(defun bad-credit (acct:string amount:decimal)
  (with-capability (CREDIT acct)        ; runs INSIDE module → admin satisfied;
    (credit acct amount)))              ; CREDIT body is `true`-equivalent → passes
```
Because `with-capability` runs inside the module (module admin satisfied) and
`CREDIT`'s body always passes, **any caller can mint from nothing**. This is the
docs' YODA6 `USER` bug — a public `hello-world` directly acquiring
`(defcap USER (account) (enforce (!= account "") ...))`.

**Fix:** never expose acquisition of a weak cap on a public path. Only acquire it
**composed under a real-guarded parent**, and keep its consumers private via
`require-capability`:

```pact
; SAFE — CREDIT only enters scope composed under DEBIT (enforce-guard) inside
; managed TRANSFER; credit is private; the pair conserves mass.
(defcap CREDIT (receiver:string) (enforce (!= receiver "") "valid receiver"))
(defun credit (account guard amount)
  (require-capability (CREDIT account))   ; private — direct call: require-capability: not granted
  ...)
(defcap TRANSFER (sender receiver amount)
  @managed amount TRANSFER-mgr
  (compose-capability (DEBIT sender))     ; real guard: enforce-guard of sender
  (compose-capability (CREDIT receiver)))
```

**Review action:** grep every `(with-capability (C ...)`; walk up to the nearest
enclosing real guard. A weak-cap acquisition on a public path with no
`enforce-guard` / scoped-managed signature / runtime context between the
entrypoint and the acquisition is a finding. See
[../skills/capability-analysis.md](../skills/capability-analysis.md) for the full
SAFE-vs-EXPLOITABLE rule.
