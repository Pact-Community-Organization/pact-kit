---
name: pact-cli-tooling
description: "Pact 5.4ce CLI/REPL tooling: .repl execution, parse check, --check-shadowing, typecheck, env-gas measurement, LCOV coverage, REPL builtins reference."
---
# Pact CLI & REPL Tooling

> Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md)
>
> **Binary location:** use the `pact` 5.4ce binary available on your `PATH`. Run experiments in a temp scratch dir, not in tracked module folders.

## Running Files
```bash
pact path/to/file.repl              # run a REPL file
pact -t path/to/file.repl           # --trace: per-expression trace output
```
- A passing `expect` is **silent**.
- A clean run ends with `Load successful`.
- **The CLI exits NON-ZERO on a REPL test failure** (since 5.1) — wire `pact file.repl` directly into CI; no extra grep needed.

## Static Checks
```bash
pact FILE                      # bare load = parse / compile check (exit 0 = "Load successful")
pact --check-shadowing FILE    # detect native shadowing
pact --version                 # should report v5.4ce (KDA-CE)
pact --lsp                     # language server for editor diagnostics
```
- Pact 5.4ce has **no `--check` flag** — a bare `pact FILE` invocation IS the load/parse check (no `expect`s run; exit 0 prints `Load successful`).
- `typecheck` is available as a native (5.2+) for static type checking. There is NO `verify` native in Pact 5.4ce (the Z3 `@model` checker is not ported) — see the Formal Verification section below.
- Note: a module whose top-level form reads tx data (`(namespace (read-msg 'ns))`) needs `env-data` — verify those via their `.repl` harness, not a bare load.
- Native name shadowing is load-time rejected in Pact 5.1+ (see canonical traps) — `--check-shadowing` surfaces it ahead of load.

## Builtin Boundary (Core vs REPL-only)
- Pact 5 splits builtins between on-chain core natives and REPL-only natives.
- `continue-pact`, `pact-state`, `expect`, `expect-failure`, and other harness helpers are REPL-only flows.
- `continue-pact` is desugared into arity-specific REPL variants (`RContinuePactRollback*`) and is not an on-chain module primitive callable from Pact module source.
- On-chain defpact progression happens through continuation command payloads (`cont` with pact-id/step/rollback/proof) interpreted by evaluator resume logic.
- When auditing module code, treat REPL-only helper usage in `.pact` source as a hard validation failure.

## Gas Measurement (no devnet needed)
The fastest way to measure gas is in the REPL — no devnet round-trip.
```pact
(env-gasmodel "table")     ;; use the real gas model
(env-gaslog)               ;; begin a gas log
(env-gas 0)                ;; reset the gas counter
(free.my-module.my-fn args)
(env-gaslog)               ;; per-op gas breakdown
(expect "under budget" true (< (env-gas) 150000))   ;; env-gas reads the counter
```
- `env-gas` with no arg **reads** the counter; `(env-gas 0)` **resets** it.
- `env-gasmodel` selects the model; `env-gaslog` emits a per-operation breakdown.

## Formal Verification — NOT a Pact 5.4ce native
`(verify …)` does **not exist** in Pact 5.4ce — the Z3 `@model` property checker
is not ported to Pact 5 core (`Semantics.md`: `verify [ ] implemented`). Use the
real static type checker instead:
```pact
(typecheck 'free.my-module)   ;; static typechecker (5.2+) — types only, NOT @model
```
`@model` annotations are parsed but **unenforced** in 5.4ce; verify properties via
REPL `expect`/`expect-failure` + devnet adversarial tests. See
[formal-verification](../skills/formal-verification.md).

## Coverage
REPL code coverage produces **LCOV** output at `coverage/lcov.info` — feed it to standard coverage reporters in CI.

## REPL env builtins — quick reference
| Builtin | Purpose |
|---------|---------|
| `env-data` | Set tx JSON payload (`read-msg`/`read-keyset` source) |
| `env-sigs` | Set signers + **scoped capability clist** |
| `env-chain-data` / `chain-data` | Set / read chain metadata (chain-id, block-time, sender, gas) |
| `env-events` | Read + clear emitted events |
| `env-gas` / `env-gasmodel` / `env-gaslog` | Gas counter / model / per-op log |
| `env-module-admin` | Grant module admin in REPL (5.0) |
| `begin-tx` / `commit-tx` | Transaction boundaries |
| `continue-pact` / `pact-state` | Advance / inspect a defpact |
| `expect` | Assert equality |
| `expect-failure` | Assert failure (**substring match** on the error) |
| `expect-that` | Assert a predicate holds |
| `test-capability` | Acquire a capability for the current test scope |

See [pact-repl-testing](../skills/pact-repl-testing.md) for test-file structure.
