---
description: "CANONICAL source of Pact 5 / KDA-CE language traps, verified behaviors, and reusable REPL error strings. All other Pact instructions, skills, agents, and prompts MUST link here instead of re-listing traps."
applyTo: ["**/*.pact", "**/*.repl"]
---
# Pact 5 / KDA-CE Canonical Trap List

> **This file is the single source of truth.** All facts below were empirically
> verified against a real `pact` 5.3 binary and official Kadena docs. Do not
> re-list traps elsewhere — link here. KDA-CE targets **Pact 5.3**.

## Read-only context (`enforce`, `try`) — CORRECTED

- **No DML (insert/update/write) inside `enforce`'s boolean argument or inside
  `try` — reads ARE allowed.** Only writes fail, with
  `Operation disallowed in read-only or sys-only mode`.
- Binding reads to a `let` first is a **style/gas preference, not a correctness
  requirement**. The old "bind DB reads to a let to avoid a read-only error" rule
  was wrong — reads inside `enforce`/`try` work.

```pact
; OK — read inside enforce
(enforce (>= (at 'balance (read accounts acct)) amount) "insufficient")
; FAILS — write inside try → Operation disallowed in read-only or sys-only mode
(try false (update accounts acct { "balance": 0.0 }))
```

## `with-default-read` — CORRECTED

- **The default object must contain every field you BIND, not every schema
  field.** Omitting an unbound field is fine.
- It fails only when you bind a field that is missing from the default:
  `Key "X" not found in object`.

```pact
; OK — default omits unbound fields, binds only "balance"
(with-default-read accounts acct { "balance": 0.0 } { "balance" := bal } bal)
```

## Native/built-in name shadowing — CORRECTED (load-time rejected)

- Shadowing a native is a **compile-time hard error in Pact 5.1+** (including
  `defun` parameters), not a silent runtime footgun:
  `Variable mod shadows native of the same name`. The module is **rejected at
  load time**.
- Never bind: `exp`, `abs`, `log`, `mod`, `round`, `ln`, `sqrt`, `floor`,
  `ceiling` (non-exhaustive — any native name).
- Detect with `pact --check-shadowing FILE`.

## `pact-id` is unsafe as a guard — CORRECTED (worse than "insufficient")

- `(pact-id)` **throws outside a defpact**:
  `Attempted to fetch defpact data, but currently not within defpact execution`.
- So `(!= "" (pact-id))` is doubly broken: it throws outside a pact, and inside
  **any** defpact it proves nothing about identity — an attacker's own defpact
  can call a `pact-id`-guarded `withdraw`.
- **Always gate with composed capabilities bound to identity**, never `pact-id`.

## Capabilities

- **`compose-capability` evaluates the composed cap's BODY eagerly** at
  acquisition time. Do not put `require-capability` for a not-yet-granted
  dependency inside a composed cap.
- **`install-capability` for `@managed` caps MUST be INSIDE the owning
  `with-capability`.**
- **`@managed` caps AND `@event` caps auto-emit an on-chain event** on
  acquisition — do not double-emit with an explicit `emit-event`.
- **Capabilities are acquirable ONLY inside the declaring module.** An external /
  foreign-module / top-level `with-capability` of a module's cap fails
  `Module admin necessary for operation but has not been acquired`. A `true`/weak
  body cap is therefore an **internal permission token, NOT public
  authorization** — `require-capability` checks scope and never re-runs the body.
- **A weak/`true`-body cap is dangerous only when a PUBLIC function
  `with-capability`s it with no upstream real guard** (YODA6 `USER` /
  `bad-credit` free-mint). Acquired only composed under a real-guarded parent
  (coin `CREDIT` under `DEBIT`) or only by runtime context (`GAS`/`COINBASE`), it
  is safe. `(defcap GOV () true)` on an upgradeable module is CRITICAL;
  `(enforce false ...)` is the correct immutability sentinel.

## Arithmetic

- **`+` is binary only**: `(+ 1 2 3)` →
  `Attempted to apply a closure to too many arguments`. Use `(+ a (+ b c))`.
- **Banker's rounding** (round-half-to-even): `(round 2.5) = 2`, `(round 3.5) = 4`.
- **Integer division floors toward −∞**: `(/ -7 2) = -4`.
- **Decimals are exact** (arbitrary precision, not IEEE-754).
- Division by zero → `Arithmetic exception: div by zero`.

## Database

- **`fold-db` is NOT a reduce.** Signature: `(fold-db table filter consumer)`
  where BOTH lambdas take `(key, obj)`; it returns a **LIST**. Reduce the result
  separately with `fold`.
- Inserting an existing key → `Value already found while in Insert mode`.
- Reading a missing key → `No value found in table ... for key:`.

## Defpacts

- **Each `(step ...)` takes exactly ONE expression** — wrap multiple ops in
  `let` / `with-capability`.
- Defpacts must be called **module-qualified**.
- `continue-pact` across a `commit-tx` needs the **pact-id explicitly**.

## Guards

- **`module` guards and `pact` guards are DEPRECATED as unsafe** (per the
  official Kadena guards doc). Use keyset / capability / user guards.
- **Principal format**: `create-principal` yields `k:<pubkey>` ONLY for a single
  valid 64-hex ed25519 key with `keys-all`; everything else → `w:<hash>:<pred>`.

## Modules

- **No circular module dependencies** — cross-module references resolve at load
  time.

## REPL testing artifacts

- **`expect-failure` does NOT roll back prior DB writes in the REPL** (within the
  same tx). Isolate each mutating `expect-failure` in its own
  `begin-tx`/`commit-tx`. On-chain a failed tx rolls back wholesale; this is a
  REPL artifact that causes **false-positive passes**.
- **`expect` does NOT stop on failure** — it records the failure and continues.
- **`test-capability` DOES run the defcap body** (acquires it for the test).
- Use specific error substrings in `expect-failure`, never `""`.

## Pact 5 version notes

- **5.0** — `let` ≡ `let*`; gas model revamp.
- **5.1** — native shadowing checks (`--check-shadowing`); CLI **exits non-zero on
  REPL test failure** (wire into CI).
- **5.2** — `typecheck` native added.
- **5.3** — read-only modref reentrancy guard; `enforce` / user-guards run
  read-only; coverage support. **KDA-CE target.**

## Reusable error strings (for `expect-failure`)

| Error string | Trigger |
|---|---|
| `Operation disallowed in read-only or sys-only mode` | DML inside `enforce` arg / `try` |
| `Value already found while in Insert mode` | `insert` on existing key |
| `No value found in table ... for key:` | `read` on missing key |
| `Key "X" not found in object` | bound a field missing from a default/object |
| `Keyset failure (keys-all)` | failed keyset enforcement |
| `Arithmetic exception: div by zero` | division by zero |
| `require-capability: not granted` | cap not in scope |
| `Module admin necessary for operation but has not been acquired` | external / top-level `with-capability` of a module's own cap |
| `Attempted to fetch defpact data, but currently not within defpact execution` | `(pact-id)` outside a defpact |
| `Attempted to apply a closure to too many arguments` | `(+ 1 2 3)` / arity error |
| `Variable X shadows native of the same name` | binding a native name (load-time) |
