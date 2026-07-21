---
description: "Use when reviewing Pact 5 code for security vulnerabilities, threat modeling, capability audits, or attack-vector design on KDA-CE."
---
# Security Rules

## STRIDE Threat Model
Apply to every module:
- **S**poofing — Can identity be forged? (keyset/guard bypass)
- **T**ampering — Can data be modified unauthorized? (unguarded writes)
- **R**epudiation — Can actions be denied? (missing event logs)
- **I**nformation Disclosure — Can data leak? (unguarded reads)
- **D**enial of Service — Can the module be blocked? (gas exhaustion)
- **E**levation of Privilege — Can roles be escalated? (capability composition)

## Pact-Specific Security Patterns

### Capability Audit Checklist
- [ ] All privileged functions require capability
- [ ] Capabilities compose correctly (no bypass via direct call)
- [ ] `@managed` capabilities have correct manager functions (subtract → enforce >= 0 → return remainder)
- [ ] No capabilities brought into scope before module reference calls
- [ ] Guard functions use `enforce-guard` not manual key checks
- [ ] `pact-id` not used as sole access guard

### Capability bodies are internal gates, not public ACLs
Security is enforced at the **acquisition site**, not in the `defcap` body. A cap
is acquirable **only inside its declaring module** — external `with-capability`
fails `Module admin necessary for operation but has not been acquired`. So a
`true`/weak-body cap is an in-module **permission token**, and `require-capability`
makes its consumers **private** (it checks scope, never re-runs the body).

- **SAFE weak cap (brief):** acquired only **composed under a real-guarded parent**
  (coin `CREDIT` under `DEBIT`'s `enforce-guard`) or only by **runtime execution
  context**; consumers private via `require-capability`; value-creating caps paired
  with a conserving counterpart (+ `@model` conservation); `@managed` where
  one-shot/budgeted; no leak across modrefs.
- **EXPLOITABLE:** any **public** function acquires the weak cap as the **sole
  gate** with no upstream real guard (YODA6 `USER`, `bad-credit` free-mint) ⇒
  **CRITICAL** (mint-from-nothing / privilege escalation).
- **Immutability sentinel:** `(enforce false "...")` = correct (deny-all ⇒
  un-acquirable ⇒ non-upgradeable). `(defcap GOV () true)` on an upgradeable module
  = **CRITICAL** (anyone seizes governance). `true`=catastrophic, `false`=safe.
- **Magic caps:** `GAS`/`COINBASE`/`GENESIS` bodies are `true` **only** because the
  node's execution machinery installs them on specific protocol paths and the
  guarded fns consume them via `require-capability` — presence of the cap *is* the
  proof of context. A `true` body is justified solely under this condition.

Canonical traps: pact-traps.md
Full audit rule + grep heuristic: ../skills/capability-analysis.md

### Common Vulnerability Patterns
1. **Unguarded admin functions** — missing `with-capability (GOVERNANCE)`
2. **Integer overflow/underflow** — Pact handles arbitrary precision, but verify boundary conditions
3. **Reentrancy** — less common in Pact but check cross-module calls
4. **Front-running** — time-dependent operations vulnerable on public mempool
5. **Gas griefing** — operations that scale gas with attacker-controlled input
6. **Phantom reads** — `with-default-read` returning zeros that bypass validation
7. **Governance-gated inputs — validate the exception, not the rule** — inputs under a real
   GOV/ADMIN signature sit inside the trust boundary; their non-validation is INFO/policy, NOT a
   finding — UNLESS a bad value silently corrupts an invariant instead of throwing (crash/
   div-by-zero = safe; a sign-flip that quietly builds a wrong schedule = finding). Validate config
   whose *sign or range* changes an invariant's direction; a self-aborting bad input needs no
   guard. (This is about inputs behind a gate that IS present; a missing gate is #1.)

### Formal Verification
- Use `@model` annotations where possible
- Property-based testing for mathematical invariants
- Verify: "sum of all balances = total supply" (conservation)
- Verify: "vote_amount ≤ balance during VOTING status" (constraint)

## Severity Classification
- **CRITICAL**: Direct fund loss, privilege escalation, governance bypass
- **HIGH**: Indirect fund loss, logic error with financial impact
- **MEDIUM**: Non-exploitable issue, gas waste, information leak
- **LOW**: Code quality, missing documentation, minor hardening

## Verdict Format
```
Findings: N critical, N high, N medium, N low
Verdict: APPROVE | NEEDS-FIX
Details: {findings with location, severity, evidence, fix}
```
