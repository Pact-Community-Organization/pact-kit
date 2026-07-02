# Examples

Canonical, runnable Pact 5 / KDA-CE example code. Every file here must pass the
kit's own gates — it doubles as the CI fixture for `scripts/pact-static-check.sh`
and as the reference for the conventions the skills and instructions describe.

## example-token

A deliberately minimal token (NOT fungible-v2 — no interface, no cross-chain)
demonstrating in ~150 lines:

| Convention | Where |
|---|---|
| Keyset governance behind a `GOVERNANCE` defcap | `example-token.pact` |
| Managed cap + manager function (linear allowance) | `TRANSFER` / `TRANSFER-mgr` |
| Capability layering (`TRANSFER` composes `DEBIT` + `CREDIT`) | capabilities section |
| `@event` cap (`MINT`) and `@managed` auto-emission | `MINT`, event tests |
| Principal-account discipline (`validate-principal`) | `create-account` |
| Trust-boundary validation (sign, precision, charset, length) | `enforce-valid-*` |
| Table reads let-bound BEFORE `enforce` (KDA-CE node rule) | `debit` |
| Scoped-signature tests, managed-install-first semantics | `example-token.repl` |
| `expect-failure` with specific REPL error substrings | throughout the suite |
| `typecheck` after load, module-hash print, gas ceiling check | suite header / footer |

Run it:

```bash
pact examples/example-token.repl          # full suite (exit 0 = green)
scripts/pact-static-check.sh examples/example-token.pact examples/example-token.repl
```

Note: `pact examples/example-token.pact` alone reports a missing-environment
warning — the module is deploy-shaped (`(namespace "free")` + admin keyset) and
verifies through its `.repl` harness, which sets that environment up.
