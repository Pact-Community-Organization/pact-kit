---
name: pact-cli-tooling
description: "Pact 5.3 CLI and REPL-native tooling — running .repl files, bare-load parse check / --check-shadowing / typecheck, env-gas measurement, verify, LCOV coverage, and the REPL env builtins quick-reference for KDA-CE."
---
# Pact CLI & REPL Tooling

> Canonical traps: [.github/instructions/pact-traps.instructions.md](../../instructions/pact-traps.instructions.md)
>
> **Binary location:** the `kadena_repl_sandbox/` symlink in this workspace is broken. Use the real binary at `<local-path>` (v5.3). Run experiments in a temp scratch dir, not in tracked module folders.

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
pact --version                 # confirm v5.3
pact --lsp                     # language server for editor diagnostics
```
- Pact 5.3 has **no `--check` flag** — a bare `pact FILE` invocation IS the load/parse check (no `expect`s run; exit 0 prints `Load successful`).
- `typecheck` is available as a native (5.2); pair with `(verify 'module)` for typing / formal verification.
- Note: a module whose top-level form reads tx data (`(namespace (read-msg 'ns))`) needs `env-data` — verify those via their `.repl` harness, not a bare load.
- Native name shadowing is load-time rejected in Pact 5.1+ (see canonical traps) — `--check-shadowing` surfaces it ahead of load.

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

## Formal Verification
```pact
(verify 'free.my-module)   ;; typechecks, then checks @model invariants/properties
```
See [formal-verification](../formal-verification/SKILL.md).

## Coverage
REPL code coverage (5.3) produces **LCOV** output at `coverage/lcov.info` — feed it to standard coverage reporters in CI.

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

See [pact-repl-testing](../pact-repl-testing/SKILL.md) for test-file structure.
