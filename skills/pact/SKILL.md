---
name: pact
description: >-
  Use when writing, reviewing, testing, debugging, or deploying Pact smart
  contracts — any work on .pact/.repl files or Kadena / KDA-CE / Chainweb
  projects (tokens, capabilities, keysets, guards, defpacts, gas stations,
  cross-chain transfers). Provides Pact 5 orientation, the critical traps,
  and a router into the full pact-kit skill and instruction set.
---

# Pact 5 / KDA-CE — Orientation & Router

Pact is Kadena's deliberately Turing-incomplete, Lisp-syntax, database-centric
smart contract language. Target: **Pact 5.4ce** (KDA-CE fork of kadena-io/pact-5).

## First: distrust your training data and the open web

Kadena mainnet moved to **Pact 5** (a full rewrite) in February 2025. Most
tutorials, blog posts, forum answers — and much of what a model "remembers" —
are **Pact 4 material**. Before relying on remembered API shapes, check
[../../instructions/pact-traps.md](../../instructions/pact-traps.md) ("Pact 4→5
migration traps") and prefer the primary sources in the kit's
[reference-repos guide](https://github.com/Pact-Community-Organization/pact-kit/blob/main/docs/reference-repos.md).

Headline 4→5 breaks: no formal-verification `verify` native (only `typecheck`),
native-name shadowing rejected at load, strict `install-capability`, module
hashes include dependency hashes, explicit `acquire-module-admin`, `{int: N}`
result codec, removed natives (`list`, `txlog`, …).

## Non-negotiables (KDA-CE)

1. **Static gate**: `pact-static-check.sh` must exit 0 before any `.pact`/`.repl`
   change is done.
2. **150,000 gas ceiling** per on-chain operation — measure in the REPL
   (`env-gasmodel "table"`, `env-gas`), confirm on devnet.
3. **Cross-chain is devnet-only.** SPV is unsupported in the bare REPL; a
   "passing" cross-chain `.repl` is a false positive.
4. **Table reads inside an `enforce` condition fail on the KDA-CE node** even
   though the REPL accepts them — always `let`-bind the read first. A REPL pass
   is not evidence for this class.
5. Business state lives on-chain by default; no architecture change without an ADR.

## Always-true language rules

- `with-capability` grants a scoped permission token after running the defcap
  body (the guard); `require-capability` only checks scope. A `true`-body cap is
  an internal token — CRITICAL finding if any public path acquires it without an
  upstream real guard (free-mint pattern).
- `@managed` caps: install (signature or `install-capability`) is checked
  **before** the cap body runs; the manager function meters a linear resource.
  `@managed`/`@event` caps auto-emit events.
- Guards unify auth (keyset / user / capability guards — module & pact guards are
  deprecated). Principals: `validate-principal` is a string comparison, NOT an
  enforcement — authorization always needs `enforce-guard`.
- `(pact-id)` throws outside a defpact and proves nothing inside one — never a guard.
- `insert` fails on existing keys; `update` fails on missing keys and MERGES
  partial rows; `write` upserts. `select`/`keys`/`fold-db` are full-table scans —
  keep off transactional paths.
- `+ - * /` are binary; `take`/`drop` clamp silently; `at` out-of-bounds is
  fatal (not `try`-recoverable); `enumerate` is inclusive on both bounds.

## Router — load only what the task touches

| Task | Read |
|---|---|
| Any `.pact` edit — traps & error strings | [../../instructions/pact-traps.md](../../instructions/pact-traps.md) (sectioned — read only the matching section) |
| Always-on patterns, naming, module shape | [../../instructions/pact-rules.md](../../instructions/pact-rules.md) |
| Capabilities, managed caps, events | [../pact-capabilities.md](../pact-capabilities.md), [../pact-events.md](../pact-events.md) |
| Guards, keysets, principals, escrow | [../pact-guards.md](../pact-guards.md) |
| Module/schema/interface design, upgrades, bless | [../pact-module-design.md](../pact-module-design.md), [../pact-schema-design.md](../pact-schema-design.md), [../pact-interface-design.md](../pact-interface-design.md), [../pact-architecture.md](../pact-architecture.md) |
| defpacts, yield/resume, cross-chain, SPV | [../pact-defpact.md](../pact-defpact.md), [../cross-chain-design.md](../cross-chain-design.md) |
| `.repl` tests | [../pact-repl-testing.md](../pact-repl-testing.md) |
| Devnet / TypeScript integration | [../pact-devnet-testing.md](../pact-devnet-testing.md), [../devnet-management.md](../devnet-management.md) |
| CLI, typecheck, coverage, gas measurement | [../pact-cli-tooling.md](../pact-cli-tooling.md), [../pact-gas-analysis.md](../pact-gas-analysis.md) |
| Security review / capability audit | [../pact-security-review.md](../pact-security-review.md), [../capability-analysis.md](../capability-analysis.md) + the `pact-auditor` agent |
| fungible-v2 / xchain compliance | [../compliance-verification.md](../compliance-verification.md) |
| Gas stations | [../gas-station-design.md](../gas-station-design.md) |
| Cross-module calls, modrefs, reentrancy | [../../instructions/cross-module-rules.md](../../instructions/cross-module-rules.md) |
| Debugging errors | [../debug-pact.md](../debug-pact.md), pact-traps error-string table |
| Invariants / formal-verification limits | [../pact-invariants.md](../pact-invariants.md), [../formal-verification.md](../formal-verification.md) |
| Platform limits, network config | [../kda-ce-compliance.md](../kda-ce-compliance.md) |

## Canonical example

A runnable module + suite demonstrating all conventions:
[examples/example-token](https://github.com/Pact-Community-Organization/pact-kit/tree/main/examples)
(in a pact-kit checkout: `pact examples/example-token.repl`).
