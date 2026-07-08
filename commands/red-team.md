---
description: "Security: Run an executable red-team pass against a Pact module — reverse-coverage + invariant hunting, 20 mutations per front executed in the interpreter, differential oracle with negative control, REPL-artifact filter, adversarial verification, reproducible report."
---
# Red Team

Offensive counterpart to `/full-security-audit`. Where the audit *reviews*, this *attacks*: it executes real `.repl` attacks against a copy of the target with the `pact` CLI and proves whether an invariant breaks. See the [red-team-testing](../skills/red-team-testing.md) skill for the full method and the [pact-auditor](../agents/pact-auditor.md) agent for the fresh-context reviewer.

**Prerequisite:** a working REPL harness — `(load "setup.repl")` that loads coin + the target module(s) + initial state, runnable with `pact <file>.repl`. If the project ships a test suite (fixtures + `setup.repl`), reuse it. Confirm it compiles before attacking.

## 5-Phase Protocol

### Phase 1 — Recon + map the known (Engine A)
Read the module and its security model. Note what it protects: money, permissions, data. Mark which attack blocks apply (economic, temporal, identity, state, composition, arithmetic, cross-chain, two-layer). Grep for omissions: every `true`-body `defcap` (map all composition paths — any public path without a real upstream guard is a free-mint), every one-sided ceiling (`<=`/`>=` → try ≤0), every conservation `enforce`, every hot `select`/loop (inflatable id, no `delete`), every payout to a free-chosen name (squatting).

### Phase 2 — State the unwritten invariants (Engine B)
Formulate properties that must hold after *every* operation, even if the contract never declares them: supply conservation, exact solvency (O(1) aggregate == O(n) naive), rounding sub-additivity, vesting monotonicity, `Σ votes ≤ circulating`, plus target-specific ones.

### Phase 3 — Execute (both engines, 20 mutations per front)
For each applicable front, write and **run** `.repl` files that (a) execute the inverted attacks with **20 mutations** (combine the six dimensions: amount, time, order, identity, prior state, repetition), and (b) assert the Phase-2 invariants. Add a **differential oracle** (naive O(n) reference vs the contract's O(1) shortcut, asserted equal each step) with a **negative control** proving the oracle would diverge on a real bug. Boundary-fuzz every parameter. Record each attempt HELD or BROKEN with before/after state.

### Phase 4 — Artifact filter (L1, non-negotiable)
Drop any "break" that depends on a REPL-only primitive (`test-capability`, `coin.GAS` magic-cap, single-DB 20-chain simulation) or on the wrong node Pact version. If it needs those crutches, it is an artifact, not a finding. When Pact blocks the obvious path, hunt the path the runtime grants and check the caller's guard there.

### Phase 5 — Adversarial verify + report
Re-run every claimed BREAK from scratch with a skeptical eye; require describing how the break looks **on-chain**; discard false positives and owner-accepted limitations. Write a report: plain-language summary, table of executed attacks (front × verdict), findings with reproducible `.repl` proof + severity, and a fix + re-test (the fix must make the attack bounce). State the honest residual (upgrade trust, cross-chain, two-layer). For a small target, one attacker suffices; for a multi-module system, run one attacker per front in parallel.

## Report note
A "held after N executed attacks" result is a legitimate, valuable deliverable — it is the independent adversarial signal that raises a contract from author-reviewed to community-reviewed. Never inflate an artifact into a finding to manufacture a result.
