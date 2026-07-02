# Reference Repositories

Vetted primary sources for Pact 5 / KDA-CE development. When kit content and one of
these disagree, the primary source wins — file an issue against the kit.

> Most Pact material on the open web is **Pact 4-era and will mislead** (mainnet moved
> to Pact 5 in February 2025). Prefer these sources over search results and over model
> training data. See `instructions/pact-traps.md` → "Pact 4→5 migration traps".

## Language & platform

| Repo | Authoritative for |
|---|---|
| [kda-community/pact-5](https://github.com/kda-community/pact-5) | The Pact 5.4ce language/runtime itself. `docs/builtins/` (176 native references), `pact-tests/pact-tests/*.repl` (368 semantics tests — `caps.repl`, `gov.repl`, `reentrancy.repl`, `defpact.repl` settle arguments), `CHANGELOG.md` (version history 1.0→5.4) |
| [kda-community/kadena-docs-new](https://github.com/kda-community/kadena-docs-new) | Official docs source. `docs/smart-contracts/install/migrate-pact5.md` is the canonical Pact 4→5 delta |
| [kda-community/KIPs](https://github.com/kda-community/KIPs) | Standards: `kip-0005/fungible-v2.pact`, poly-fungible, account protocols |

## Libraries & tooling

| Repo | Authoritative for |
|---|---|
| [CryptoPascal31/pact-util-lib](https://github.com/CryptoPascal31/pact-util-lib) | The community stdlib (`free.util-*` on mainnet): lists, math, strings, time (safe-time wrappers), fungible validation helpers, ZK. Also the reference CI pattern (download release binary, run `.repl`, grep FAILURE) and test-file style |
| [CryptoPascal31/kadena_repl_sandbox](https://github.com/CryptoPascal31/kadena_repl_sandbox) | The community-standard REPL environment: `kda-env/init.repl` preloads guards, namespaces, coin, util-lib, marmalade, and funded test accounts |

## Production contracts (style & idioms)

| Repo | Study it for |
|---|---|
| [brothers-DAO/bro-token](https://github.com/brothers-DAO/bro-token) | Reference fungible-v2 + fungible-xchain-v1 implementation: `bless` chains, DEBIT/CREDIT/TRANSFER layering, one-shot `TRANSFER_XCHAIN` manager, auto-managed `ROTATE`, one-time-init table |
| [brothers-DAO/bro-dex](https://github.com/brothers-DAO/bro-dex) | On-chain order book: event-cap over internal-cap layering, core/wrapper/view module split (gas), **m4 macro templating** for parameterized modules (Pact has no generics), `tests/stubs/` pattern |
| [brothers-DAO/bro-lottery](https://github.com/brothers-DAO/bro-lottery) | Oracle-fed randomness, stub-based testing |
| [CryptoPascal31/cyKlone](https://github.com/CryptoPascal31/cyKlone) | ZK (groth16) usage and the reference **gas-station** with drain defense (exact gas price/limit + exec-code allowlist) |
| [CryptoPascal31/kadena-btc-oracle](https://github.com/CryptoPascal31/kadena-btc-oracle) | Trust-minimized oracle design |
| [kda-community/dao-voting](https://github.com/kda-community/dao-voting) | Base-chain pattern (single-chain proposals), coin-account-ownership cap |
| [daplcor/oracle](https://github.com/daplcor/oracle), [daplcor/Credits](https://github.com/daplcor/Credits) | GOV/OPS keyset split, principal namespaces (`n_<hash>`), median aggregation, heavy util-lib reuse |

## Cross-cutting idioms these repos agree on

- SPDX header + `VERSION` defconst + docstring linking docs/GitHub in every module.
- Explicit import lists: `(use free.util-lists [first last])`.
- Capabilities: public caps carry `@event` and compose `true`-bodied internal permission
  caps; internal functions gate on `require-capability`.
- Validation helpers named `enforce-*` returning bool; starred variants (`enforce-reserved*`)
  are the stricter form.
- Tests: `(enforce-pact-version …)` header, `(typecheck "mod")` after load, module-hash
  print, `expect-failure` with specific substrings, `expect-that` + composed predicates.
