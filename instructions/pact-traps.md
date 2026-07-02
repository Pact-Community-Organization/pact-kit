---
description: "On-demand canonical traps reference for Pact 5 / KDA-CE. REPL/on-chain error strings and verified behaviors. NOT auto-loaded — pull only the section you need."
---
# Pact 5 / KDA-CE Canonical Trap List

> **Single source of truth — load on demand.** Every fact below was empirically
> verified against the `kda-community/pact-5` Haskell source (v5.4ce).
> Do not re-list traps elsewhere — link here. KDA-CE targets **Pact 5.4ce**.
>
> **Token-efficient use:** this file is a sectioned reference, not auto-injected.
> The lean always-on summary lives in
> [pact-rules.md](pact-rules.md). **Read only the
> section(s) your task touches** — find the `##` heading in the index and read that
> range; do not load the whole file. Each fact lives here exactly once.

## Section index — read only what your task needs

| When your task involves… | Read section (`##` heading) |
|---|---|
| any Pact code — always-true invariants | Read-only context · with-default-read · Native/built-in name shadowing · pact-id is unsafe as a guard |
| capabilities / `with-capability` / managed caps / events | Capabilities |
| numbers, decimals, rounding, division, `^`/`sqrt`/`ln` | Arithmetic |
| tx input — `read-msg`/`read-integer`/`read-decimal`/`read-keyset` | Message Data — read-* |
| tables — insert/update/write/select/keys/fold-db | Database |
| `take`/`drop`/`at`/`enumerate`/`zip`/`format`/`contains`/`sort` | List / String / Object natives |
| `time`/`add-time`/`diff-time`/`block-time` — deadlines, vesting | Time |
| accounts — `create-principal`/`validate-principal`, k:/w:/r: | Principals |
| `chain-data`/`tx-hash`/`is-charset` — "now"/height/sender | Environment |
| `if`/`and`/`or`/`enforce`/`enforce-one`/`cond` | Control flow |
| `map`/`filter`/`fold`/`zip`/`bind`/`compose` | Higher-order list natives |
| `hash`/`hash-keccak256`/`hash-poseidon`/`base64-*`/ZK/`pairing-check` | Hashing / crypto / ZK |
| defpacts — steps, yield/resume, cross-chain, SPV | Defpacts · Source-Anchored Defpact Traps |
| keysets, guards, principal prefixes | Guards |
| cross-module refs / circular deps | Modules |
| writing `.repl` tests | REPL testing artifacts · Pact 5 version notes |
| migrating / reviewing Pact 4-era code or tutorials | Pact 4→5 migration traps |
| asserting error substrings (REPL Pretty vs on-chain BoundedText) | Reusable error strings: REPL vs. on-chain rendering |

## Read-only context (`enforce`, `try`)

- **No DML (insert/update/write) inside `enforce`'s boolean argument or inside
  `try`.** Writes fail with
  `Operation disallowed in read-only or sys-only mode` (on-chain: `Operation is not allowed in read-only or system-only mode.`)
- **⚠️ REPL vs ON-CHAIN DIVERGENCE — table READS inside an `enforce` condition work in the
  REPL but FAIL on the KDA-CE chainweb-node** with
  `Error during database operation: Operation is not allowed in read-only or system-only mode.`
  Empirical, devnet-verified 2026-07-01: a full `.repl` suite passed green while the first
  on-node transaction hitting an `(enforce (<table-reading-expr>) …)` aborted. The Pact 5.3
  REPL change ("enforce runs read-only — reads permitted") is TRUE FOR THE REPL ONLY; the
  deployed node still rejects the read. **Rule: ALWAYS bind any table-reading expression to a
  `let` BEFORE the `enforce` — on-chain this is a CORRECTNESS requirement. A REPL pass is not
  evidence for this class; only devnet is.**
- Reads in the **argument position of `enforce-guard`** (e.g. `(enforce-guard (account-guard s))`
  inside a defcap body) are safe on-chain — the argument evaluates before the guard enforcement
  (devnet-proven via DEBIT/VOTE-style caps). [UNVERIFIED on-chain: whether a keyset lookup inside
  an `enforce-one` condition trips the same node check — hoist/bind to be safe.]

```pact
; REPL-only OK — FAILS on the KDA-CE node (read inside the enforce condition)
(enforce (>= (at 'balance (read accounts acct)) amount) "insufficient")
; CORRECT everywhere — bind first
(let ((bal (at 'balance (read accounts acct))))
  (enforce (>= bal amount) "insufficient"))
; FAILS everywhere — write inside try → Operation is not allowed in read-only or system-only mode.
(try false (update accounts acct { "balance": 0.0 }))
```

## `with-default-read`

- **The default object must contain every field you BIND, not every schema
  field.** Omitting an unbound field is fine.
- It fails only when you bind a field that is missing from the default:
  `Key "X" not found in object`.

```pact
; OK — default omits unbound fields, binds only "balance"
(with-default-read accounts acct { "balance": 0.0 } { "balance" := bal } bal)
```

## Native/built-in name shadowing (load-time rejected)

- Shadowing a native is a **compile-time hard error in Pact 5.1+** (including
  `defun` parameters), not a silent runtime footgun:
  `Variable mod shadows native with the same name`. The module is **rejected at
  load time**.
- Never bind: `exp`, `abs`, `log`, `mod`, `round`, `ln`, `sqrt`, `floor`,
  `ceiling` (non-exhaustive — any native name).
- Detect with `pact --check-shadowing FILE`.

## `pact-id` is unsafe as a guard

- `(pact-id)` **throws outside a defpact**:
  `Attempted to fetch defpact data, but currently not within defpact execution` (on-chain: `Attempt to fetch defpact data failed because there's no defpact currently being executed.`)
- So `(!= "" (pact-id))` is doubly broken: it throws outside a pact, and inside
  **any** defpact it proves nothing about identity — an attacker's own defpact
  can call a `pact-id`-guarded `withdraw`.
- **Always gate with composed capabilities bound to identity**, never `pact-id`.

## Capabilities

- **`compose-capability` evaluates the composed cap's BODY eagerly** at
  acquisition time. Do not put `require-capability` for a not-yet-granted
  dependency inside a composed cap.
- **`install-capability` is not an "inside owning with-capability" evaluator
  requirement.** The hard runtime checks are: not callable within a defcap body
  (`FormIllegalWithinDefcap`), target must be valid managed metadata
  (`InvalidManagedCap`), and duplicate installs fail (`CapAlreadyInstalled`).
  A managed cap acquired via `with-capability` without a prior install or
  matching signature fails `CapNotInstalled`.
- **`@managed` caps AND `@event` caps auto-emit an on-chain event** on **normal
  acquisition** (`with-capability`); `test-capability` does NOT emit. Do not
  double-emit with an explicit `emit-event`. (Source: `evalCap` — emission is
  guarded by `NormalCapEval` and uses the original, unfiltered token args.)
- **`emit-event` requires an `@event` or `@managed` cap and is module-scoped.**
  On a plain cap it fails `InvalidEventCap`; emitting a cap from outside its
  owning module fails `EventDoesNotMatchModule`. It evaluates no cap body and
  returns `true`. (Source: `coreEmitEvent`; `emitEvent` in
  `pact/Pact/Core/IR/Eval/Runtime/Utils.hs`; static test `emit_event_module_mismatch`.)
- **Capabilities are acquirable ONLY inside the declaring module.** An external /
  foreign-module / top-level `with-capability` of a module's cap fails
  `Module admin necessary for operation but has not been acquired` (on-chain: `Module admin is necessary for operation but has not been acquired:`). A `true`/weak
  body cap is therefore an **internal permission token, NOT public
  authorization** — `require-capability` checks scope and never re-runs the body.
- **A weak/`true`-body cap is dangerous only when a PUBLIC function
  `with-capability`s it with no upstream real guard** (YODA6 `USER` /
  `bad-credit` free-mint). Acquired only composed under a real-guarded parent
  (coin `CREDIT` under `DEBIT`) or only by runtime context (`GAS`/`COINBASE`), it
  is safe. `(defcap GOV () true)` on an upgradeable module is CRITICAL;
  `(enforce false ...)` is the correct immutability sentinel.

## Arithmetic

- **`+ - * /` are BINARY only** (arity 2) and **overloaded**: int⊕int→int,
  any-mix-with-decimal→decimal; `+` also concatenates string⊕string and list⊕list.
  `(+ 1 2 3)` → `Attempted to apply a closure to too many arguments`; use
  `(+ a (+ b c))`.
- **Mixed int/decimal promotes to decimal**: `(+ 1 2.0)` = `3.0`. **AVOID relying on
  implicit promotion — promote explicitly with `(dec i)`** (e.g. `(+ (dec 1) 2.0)`) so the
  types are unambiguous at the call site and no silent int→decimal happens. *(auditor: Pascal Kda)*
- **Decimals are EXACT** arbitrary-precision (`Data.Decimal`), never IEEE-754 — so
  `+ - * /` on decimals are exact. Only the **transcendentals** (`exp`, `ln`, `sqrt`,
  `log`, decimal `^`) go through MPFR and can fail `FloatingPointError` on NaN/∞.
- **Rounding — two shapes** (`roundingFn` over `roundTo'`):
  - 1-arg `(round d)` / `(floor d)` / `(ceiling d)` → **integer**.
  - 2-arg `(round d prec)` / `(floor d prec)` / `(ceiling d prec)` → **decimal** to
    `prec` places (`prec` clamped to `>= 0`). (`round-prec`/`floor-prec`/`ceiling-prec`
    are the same natives; user text is `round`/`floor`/`ceiling`.)
  - `round` uses **banker's rounding** (round-half-to-even): `(round 2.5) = 2`,
    `(round 3.5) = 4`. `floor` → −∞, `ceiling` → +∞.
- **Integer `/` is floor division toward −∞** (`div`): `(/ -7 2) = -4`. `mod` matches
  (`(mod -7 2) = 1`).
- **Division by zero** → `Arithmetic exception: div by zero` (int) /
  `Arithmetic exception: div by zero, decimal` (decimal).
- **`^` (pow)**: int^int with a **negative exponent** →
  `Arithmetic exception: negative exponent in integer power`; decimal `0 ^ <neg>` →
  `Floating point error: zero to a negative power is undefined`.
- **`sqrt`/`ln` domain errors**: `(sqrt <neg>)` →
  `Arithmetic exception: Square root must be non-negative`; `(ln x)` with `x <= 0` →
  `Arithmetic exception: Natural logarithm must be greater then 0`; `log` rejects
  base `1`, base `< 0`, and non-positive arg.
- **`dec`** converts an integer to a decimal (`(dec 3)` = `3.0`).
- **Decimal literal precision cap**: a literal with **≥ 255 decimal places** fails at
  parse with `Precision overflow (>=255 decimal places)`.
- **`enforce-unit` is NOT a Pact native** — it is a fungible-v2 interface function;
  tokens implement it as `(= (floor amount precision) amount)` to reject
  over-precise amounts. Always enforce unit/precision on external decimal inputs.

## Message Data — `read-*` (TRUST BOUNDARY)

> `read-*` are the entry points for ALL external tx input — treat every value as
> attacker-controlled. Source: `eeMsgBody` (set by `env-data` in REPL; the tx `data`
> payload on-chain). The body is a top-level object; if it is not an object, every
> `read-*` fails.

- **`(read-msg key)`** returns the stored value at `key` **as-is** — `coreReadMsg` just
  `M.lookup`s the key in `eeMsgBody` and returns the `PactValue` unchanged (no coercion *at
  the `read-msg` call site*). **BUT the value it returns was already type-coerced when the
  JSON tx payload was decoded into `eeMsgBody`** per Pact's JSON→PactValue rules (a JSON
  number becomes `PInteger`/`PDecimal`, an object becomes `PObject`, etc.). So `read-msg`
  does not "add" coercion, yet you are NOT guaranteed a raw/verbatim JSON shape — you get a
  decoded `PactValue` whose type is whatever the decoder chose. `(read-msg)` (no arg) returns
  the **entire** decoded data body. Always validate type/range before use. *(auditor: Pascal
  Kda flagged the old "no type coercion" wording; corrected against `coreReadMsg` in
  `pact/Pact/Core/IR/Eval/CEK/CoreBuiltin.hs`.)*
- **`(read-string key)`** accepts **only** a string value — no coercion. A number/object
  at that key is a recoverable read failure.
- **`(read-integer key)` COERCES** — it accepts an integer (as-is), a **decimal (which it
  silently `round`s — banker's rounding!)**, or a numeric **string** (parsed). So
  `read-integer` on `2.5` yields `2`, on `"3"` yields `3`. **Never assume the caller sent
  an int** — a fractional amount is silently rounded.
- **`(read-decimal key)` COERCES** — accepts a decimal (as-is), an integer (`→ N.0`), or a
  numeric string (int-or-decimal parsed). Pair with `enforce-unit`/precision checks.
- **`(read-keyset key)`** reads the keyset object; under the `FlagEnforceKeyFormats` exec
  flag it validates key formats and fails `InvalidKeysetFormat`. Returns a keyset guard.
- **All `read-*` are `try`-recoverable** (Pact 4.7+). A **missing key OR a wrong-type
  value** raises the recoverable `EnvReadFunctionFailure` — so
  `(try "default" (read-string 'k))` yields the default if `'k` is absent/ill-typed.
  This is a `UserRecoverableError`, so a bare unguarded `read-*` **aborts the tx** on a
  bad/missing key. Decide explicitly: guard with `try` (optional) or let it abort (required).
- **Security:** validate ranges/signs/precision on every read amount; never trust
  `read-keyset` content as authorization without `enforce-guard`; never branch trust on
  `read-msg` without validation.

## Database

- **Write-type distinctions** (`WriteType` in `Persistence/Types.hs`; `write'` in
  `CoreBuiltin.hs`):
  - `insert` — fails if the key **already exists**; requires a **complete** row
    (full schema check, `checkSchema`).
  - `update` — fails if the key **does NOT exist**; accepts a **partial** row
    (`checkPartialSchema`) and **merges** it over the existing row — unspecified
    columns are unchanged (`RowData (M.union new old)`).
  - `write` — upsert (insert-or-replace); requires a **complete** row.
- **`update` is a partial merge, not a replace** — only the columns you pass
  change; the rest of the row is preserved.
- A write whose object doesn't match the table schema fails
  `WriteValueDidNotMatchSchema` (insert/write check the full schema; update a
  partial one).
- **`fold-db` is NOT a reduce.** Signature: `(fold-db table filter consumer)`
  where BOTH lambdas take `(key, obj)`; it returns a **LIST**. Reduce the result
  separately with `fold`.
- **Every user-table op requires the calling code to be INSIDE the owning module
  or to hold that module's admin** (`guardForModuleCall` inside `guardTable`). You
  cannot read or write another module's table without its module admin — except
  read-class ops in `/local` when `FlagAllowReadInLocal` is set.
- **`select` / `keys` / `fold-db` are FULL-TABLE SCANS** (`_pdbKeys` over the
  entire table) carrying a heavy `_gcSelectPenalty`. Pact 5 core does **not**
  hard-restrict them to local (unlike the truly local-only natives below), but
  their unbounded gas + key-ordering dependence make them **unsafe on
  transactional/on-chain paths** — keep them to `/local` reads. [UNCERTAIN] the
  exact KDA-CE chainweb-node gating of these is not verified here.
- **Truly local-only natives** (throw `OperationIsLocalOnly` in transactional
  mode): `txlog`, `txids`, `keylog`, `list-modules`, `describe-module`.
- `create-table` is **top-level only** (`enforceTopLevelOnly`) and requires module
  admin.
- Inserting an existing key → `Value already found while in Insert mode` (on-chain: `Insert failed because the value already exists in the table:`).
- Updating a missing key → `No row found during update in table` (on-chain: `Update failed because no row was found in table:`).
- Reading a missing key (`read` / `with-read`) → `No value found in table` … `for key:` (both surfaces).

## List / String / Object natives (TRUST-BOUNDARY clamping)

> `take`/`drop`/`at`/`enumerate`/`format` appear in nearly every contract and carry
> silent-clamp and inclusive-bound traps. Verified in
> `pact/Pact/Core/IR/Eval/CEK/CoreBuiltin.hs` + `pact/Pact/Core/Errors.hs` + `StaticErrorTests.hs`.

- **`take` / `drop` SILENTLY CLAMP — they never raise on an out-of-range count**
  (source `Note: [Take/Drop Clamping]`). `(take 100 [1 2 3])` → `[1 2 3]`; `(take -100 [1 2 3])` → `[1 2 3]`.
  A **negative** count operates from the END: `(take -2 xs)` = last 2; `(drop -2 xs)` = all but last 2.
  Both are overloaded over **string, list, AND object**; the object form is a KEY filter
  (`(take [keys] obj)` keeps those keys, `(drop [keys] obj)` removes them) and **missing keys are silently ignored**.
  → Never use `take`/`drop` as a bounds check; validate `length` first.
- **`at` is NOT polymorphic over strings.** Only `(at idx list)` and `(at field object)` exist.
  Index a string char with `(at idx (str-to-list s))` (exactly what `pact-util-lib`'s `char-at` does).
- **`at` out-of-bounds is a FATAL, non-`try`-recoverable error** (source comment: "not recoverable in prod").
  `(at 3 [1 2 3])`, `(at -1 [1 2 3])` (a negative index does NOT wrap), and `(at 0 [])` all throw
  `ArrayOutOfBoundsException`; `(at 'missing obj)` throws `ObjectIsMissingField`. These are `EvalError`/execution
  errors, NOT `UserRecoverableError`, so `try` does not catch them. Guard with `contains`/`length` first.
- **`enumerate` is INCLUSIVE on BOTH bounds.** `(enumerate 0 N)` yields **N+1** elements (`0..N`);
  `(enumerate 5 5)` → `[5]`. The 2-arg form auto-picks step ±1. The 3-arg `(enumerate from to step)`
  raises `EnumerationError` if the step diverges from the interval; `step = 0` → empty list.
- **`zip` truncates to the SHORTEST list** — no error on unequal lengths.
- **`length` works on string (char count), list, AND object (key count).** `reverse` works on string + list.
  `distinct` preserves first-seen order and is **O(n²)** gassed-equality — costly on large lists.
- **`contains` arg order is `(contains item collection)`**: substring test for strings
  (`(contains "foo" "foobar")`), key membership for objects (`(contains 'k obj)`),
  element membership for lists (`(contains 2 [1 2 3])`).
- **`format` uses literal `{}` placeholders** (`(format "{} {}" [a b])`). A template with **no** `{}`
  returns unchanged (args ignored). Too few args (placeholders exceed args by >1) → native execution error
  `not enough arguments for template`; **extra args are ignored**. `format` renders a string arg
  **raw/unquoted** — unlike `show`, which quotes it (`(format "{}" ["hi"])` → `hi`; `(show "hi")` → `"hi"`).
  Use `format` for user-facing messages/events; never assume it quotes.
- **`str-to-int`** parses base-10 by default; `(str-to-int base s)` supports bases 2–16 and 64 (base64url).
  **`int-to-str`** requires a non-negative value (`int-to-str error: cannot show negative integer`)
  and base 2–16 or 64.

## Time (`time` / `add-time` / `diff-time` / `block-time` — OVERFLOW + UTC traps)

> Time appears in every deadline / vesting / voting-window contract. Internally a `time`
> is `PactTime.UTCTime` at **microsecond** resolution, stored as a **signed int64 of
> microseconds from the TAI epoch (1858-11-17)**. Verified in
> `pact/Pact/Core/IR/Eval/CEK/CoreBuiltin.hs` + `pact/Pact/Core/PactValue.hs` and against
> Pascal's mainnet `free.util-time`.

- **There is NO current-time / `now` native.** On-chain "now" is `(at 'block-time (chain-data))`
  — but this is the **timestamp of the PARENT (previous) block, NOT the current block** (the
  current block's time is not known during execution). It is a **deterministic consensus value**,
  NOT wall-clock real time, and it **lags real time by roughly one block**. `chain-data` is the
  only source; never assume sub-block-time precision, real-time behaviour, or that "now" equals
  the current block's time. (`free.util-time` wraps this as `(now)` via
  `free.util-chain-data.block-time`.) *(auditor: Pascal Kda — value is populated by chainweb-node,
  not pact-5.)*
- **`(time s)` accepts ONLY the fixed ISO8601 UTC literal `%Y-%m-%dT%H:%M:%SZ`** (trailing `Z`,
  no timezone offsets). Any other shape → native execution error `time default format parse failure`.
  For other layouts use `(parse-time fmt s)` (strftime codes, e.g. `%F`, `%T`, `%Y-%b-%d`); a
  non-matching string → `parse-time parse failure`. `(format-time fmt t)` renders via the same
  strftime codes; default serialization is second-resolution ISO unless you use `%v` for microseconds.
- **`add-time` / `diff-time` / `time` / `parse-time` CAN SILENTLY OVERFLOW** — they wrap Haskell's
  time library (signed int64 microseconds) with **no bounds check**, so a huge offset or far-future/
  far-past date wraps around instead of erroring. With **user-supplied** times/offsets this is a real
  security bug (deadline/vesting bypass). **Mitigation (reimplement Pascal's pattern inline):** bound
  every user time/offset to ±(2^62/1e6 − 1) seconds, and detect parse overflow by round-tripping —
  `(enforce (= in (format-time fmt t)) "Unsafe time conversion")`. `free.util-time` exposes
  `time-safe` / `parse-time-safe` / `add-time-safe` / `diff-time-safe` doing exactly this (Beta/UNAUDITED — copy, don't trust-depend).
- **`(add-time t secs)`** adds seconds (decimal OR integer) to a time → time. **`(diff-time a b)`**
  returns **signed decimal seconds** `a − b`. Time values are ordered, so `< <= > >= =` work directly
  (use them for deadline checks).
- **`hours` / `minutes` / `days` return decimal SECONDS (a duration), not a time** — `(days 1)` →
  `86400.0`. They exist to feed `add-time`: `(add-time t (days 1))`. Accept int or decimal.
- **Unix timestamp** is not a native: compute `(diff-time t (time "1970-01-01T00:00:00Z"))` (decimal
  seconds; `floor` for an integer stamp). The internal/Haskell epoch (1858-11-17) is different from the
  Unix epoch (1970-01-01) — never conflate them.
- Gas (table model): `time`/`parse-time`/`format-time` = 500; `add-time`/`diff-time`/`hours`/`minutes`/`days` = 250.

## Principals — identity strings (`create-principal` / `validate-principal` — TRUST BOUNDARY)

> Principals are deterministic string identities derived from a guard. Verified in
> `pact/Pact/Core/Principal.hs` (parser + `mkPrincipalIdent` + `showPrincipalType`),
> `createPrincipalForGuard` in `pact/Pact/Core/IR/Eval/Runtime/Utils.hs`, and
> `PrincipalTests.hs`. Prefix taxonomy lives in the `pact-guards` skill — do not re-list it.

- **`validate-principal` does NOT enforce the guard — it is a STRING COMPARISON.**
  `(validate-principal guard principal-string)` reconstructs the principal string FROM the
  guard (`createPrincipalForGuard`) and checks it `==` the supplied string. It returns a
  bool proving "this string is the canonical principal for this guard" — it proves **nothing**
  about whether the caller actually satisfies that guard. **Authorization still requires a
  separate `(enforce-guard guard)`.** Using `validate-principal` alone as an auth check is a
  real privilege-escalation bug.
- **`is-principal` / `typeof-principal` are FORMAT-ONLY and never throw.** `is-principal`
  returns a bool (does the string parse as any principal?); `typeof-principal` returns the
  prefix (`"k:"`, `"w:"`, `"r:"`, `"u:"`, `"m:"`, `"p:"`, `"c:"`) or **`""`** for a
  non-principal — it does NOT error on bad input. Neither validates that the underlying
  guard is satisfiable; they only check shape.
- **`create-principal` is the single canonical guard→string map** (`(create-principal guard)`).
  It is deterministic and total for a valid guard. The `k:` form is produced **only** for a
  single valid 64-hex ed25519 key with the `keys-all` predicate; every other keyset (multi-key,
  non-`keys-all`, or non-ed25519) yields `w:<b64url-hash-of-pubkeys>:<pred>`. So you cannot
  assume a keyset guard maps to `k:`.
- **Account-name ⟺ guard binding is NOT automatic.** A row's account string and its stored
  `guard` are independent unless you bind them. Enforce the binding at create/credit time with
  `(enforce (validate-principal guard account) "...")` (the coin `enforce-reserved` pattern),
  AND enforce the guard itself (`enforce-guard`) for any privileged action. `free.util-fungible`'s
  `enforce-reserved` is exactly this `validate-principal` check (Beta/UNAUDITED — copy-inline).

## Environment — `chain-data` / `tx-hash` / `is-charset`

> `chain-data` is the on-chain trust source for "now", height, and gas context — it is the
> base the time cluster's "now" depends on. Verified in `pact/Pact/Core/ChainData.hs`
> (the `cd*` field constants + `PublicData`/`PublicMeta`) and `coreChainData` in
> `pact/Pact/Core/IR/Eval/CEK/CoreBuiltin.hs`.

- **`(chain-data)` returns EXACTLY 7 fields** (object), no more: `chain-id` (string),
  `block-height` (integer), `block-time` (time), `prev-block-hash` (string), `sender` (string),
  `gas-limit` (integer), `gas-price` (decimal). **`gas-fee` appears in the prose docs but is NOT
  in the returned object** — reading `(at 'gas-fee (chain-data))` throws missing-field. `ttl` and
  `creation-time` are also dropped (they live in `PublicMeta` but are not surfaced).
- **`sender` is the GAS-PAYER account, not the operation's signer/authorizer.** Never use
  `(at 'sender (chain-data))` as an authorization identity — it is the account paying gas, fully
  attacker-controllable in the tx envelope. Authorize with keysets / `enforce-guard`, never `sender`.
- **`block-time` / `block-height` are DETERMINISTIC consensus values, not wall-clock/live height.**
  **`block-time` is the timestamp of the PARENT (previous) block, NOT the current block**
  (microseconds since UNIX epoch internally); the current block's time is not available during
  execution, so on-chain "now" (there is no `now` native) actually lags real time by ~one block.
  Both `block-time` and `block-height` are identical for every tx in the same block — do not assume
  intra-block ordering or sub-block-time granularity, and do not treat `block-time` as the exact
  current instant for tight deadlines. *(auditor: Pascal Kda — `block-time` is supplied by
  chainweb-node in `PublicData`, not by pact-5; `pact/Pact/Core/ChainData.hs` only defines the field.)*
- **In bare REPL every field is a zero/empty DEFAULT** (`chain-id ""`, `block-height 0`,
  `block-time 1970-01-01T00:00:00Z`, `sender ""`, `gas-limit 0`, `gas-price 0.0`). Set them in tests
  with `(env-chain-data { ... })` — a REPL-only native; forgetting it gives false time/height results.
- **`(at 'field (chain-data))` is the only access path** — there is no per-field native; `free.util-chain-data`
  is just thin `(at 'field (chain-data))` wrappers (`chain-id`/`block-time`/`sender`/… ; Beta/UNAUDITED — copy-inline).
- **`is-charset`**: `(is-charset 0 s)` = all-ASCII, `(is-charset 1 s)` = all-Latin-1 (a.k.a.
  `CHARSET_ASCII` / `CHARSET_LATIN1`); any other charset id → native execution error
  `Unsupported character set`. Returns bool; use for account-name / input validation.
- **`(tx-hash)`** returns the current transaction's hash string (env `eeHash`); deterministic within a tx.
- Gas (table model): `chain-data` = 500, `is-charset` = 500, `tx-hash` = basic-work.

## Control flow — `if` / `and` / `or` / `enforce` / `enforce-one` (SPECIAL FORMS)

> `if`/`and`/`or`/`enforce`/`enforce-one`/`with-capability`/`try`/`create-user-guard`/`cond` are
> **`BuiltinForm` SPECIAL FORMS, not natives** — they capture terms and evaluate them LAZILY
> (distinct desugar/eval path; no `builtinArity`; cannot be passed as first-class values without
> eta-expansion). The point-free `and?`/`or?`/`not?`/`where` ARE natives. Verified in
> `pact/Pact/Core/IR/Eval/CEK/Evaluator.hs` (CondC/EnforceOne handler) + `Direct/Evaluator.hs` + `Builtin.hs` (`BuiltinForm`).

- **`and` / `or` SHORT-CIRCUIT and require ACTUAL `bool` operands** (not "truthy" — a non-bool
  result raises an `enforceBool` error). `(and a b)` skips `b` when `a` is false; `(or a b)` skips
  `b` when `a` is true. Use this to order cheap/likely checks first.
- **`if` takes exactly 3 args** `(if cond then else)`; `cond` must be a bool; only the taken branch
  is evaluated.
- **`enforce`** `(enforce cond msg)`: `cond` runs in a **read-only** env (Pact 5.4ce — reads OK, writes
  fail), and the **`msg` is LAZY** — it is evaluated ONLY when `cond` is false (so a `format`/`show`
  in the message costs nothing on the happy path). Failure raises a recoverable `UserEnforceError msg`.
- **`enforce-one` SWALLOWS errors in its conditions — this is its defining behaviour.**
  `(enforce-one msg [c1 c2 …])` evaluates each condition (read-only env, left to right) and treats a
  condition that **throws a recoverable error as `false`** (`catchRecoverable … -> false`), continuing
  to the next; it returns `true` on the **FIRST** condition that yields `true`, and only if **all**
  conditions fail or throw does it raise `UserEnforceError msg`. An **empty list** raises an internal
  enforce error. **Trap:** it catches only `UserRecoverableError` (failed `enforce`/guard/`enforce-one`)
  — a true execution error (gas exhaustion, disallowed DB write, array-OOB) still aborts the whole tx,
  NOT swallowed. Never rely on `enforce-one` to "try/catch" non-guard logic.
- **`enforce-one` arg order is `(enforce-one msg [conditions])`** — message FIRST, then the list. Each
  list element is a full expression evaluated lazily, not a precomputed bool.
- **`and?` / `or?` / `not?` / `where` are point-free NATIVES** (arity 3/3/2/3), distinct from the
  special forms: `(and? f g x)` applies `x` to `f` then (short-circuit) `g`; `(or? f g x)`,
  `(not? f x)`; `(where 'field f obj)` applies `f` to `obj`'s field value -> bool and is the building
  block for `select`/`filter` predicates. `where` on a **missing field throws fatal `ObjectIsMissingField`**
  (not `try`-recoverable).
- **`cond`** is sugar: `(cond (test1 r1) (test2 r2) … default)` desugars to nested `if`s — there is no
  runtime `cond` branching native beyond that lowering.
- Gas: condition special-form reductions are charged as cheap uncons/node work; `and?`/`or?`/`not?`/`where` ≈ basic-work + the cost of the applied closures.

## Higher-order list natives — `map` / `filter` / `fold` / `zip` / `bind` / `compose`

> These are the functional backbone of every batch/aggregate op (dividend distribution, vote
> tallying) and drive almost all of `free.util-lists`. They are real NATIVES (not special forms).
> Verified in `pact/Pact/Core/IR/Eval/CEK/CoreBuiltin.hs` (`coreMap`/`coreFilter`/`coreFold`/`zipList`/`coreBind`/`coreCompose`)
> + the `MapC`/`FoldC`/`ZipC`/`FilterC` continuation frames in `Evaluator.hs` + `TableGasModel.hs`.

- **They charge gas PER ELEMENT, not flat.** The table cost is only `_gcNativeBasicWork`; the real
  cost is `chargeUnconsWork` charged for **each** list element plus the cost of the applied closure.
  A `map`/`fold`/`filter`/`zip` over a large or unbounded list is the #1 gas-blowout vector — never
  iterate an attacker-growable list on a transactional path; cap length first.
- **The closure runs in the AMBIENT context, NOT read-only.** Unlike `enforce`/`try`/user-guard
  bodies (forced read-only), a `map`/`fold`/`filter` lambda CAN perform DB writes and acquire
  capabilities if the surrounding code is transactional. Powerful but a footgun — a side-effecting
  map over a list mutates state N times.
- **`fold` is `(fold fn init [list])`** — left fold, `fn` takes `(acc elem)`; an **empty list returns
  `init` unchanged** (the closure is never called). This is the reduce primitive (`fold-db` is NOT — see Database).
- **`map` is `(map fn [list])`** → new list of `fn` applied to each; **`filter` is `(filter pred [list])`**
  where `pred` must return an actual `bool` (non-bool → enforceBool error); **`zip` is `(zip fn [a] [b])`**
  applying `fn(a_i,b_i)`, truncating to the **shortest** list (no error on unequal lengths).
- **`bind` is `(bind obj { 'field := var, … } body)`** — OBJECT destructuring (NOT a monadic bind).
  It desugars to a 1-arg lambda over the object with `at`-accesses for each bound field, then runs
  `body`; a bound field absent from the object throws fatal `ObjectIsMissingField` (not `try`-recoverable).
  Use it to pull several fields out of a `read`/object in one form.
- **`compose` is `(compose f g x)` = `g(f(x))`** — strict, left-to-right (apply `f` to `x`, then `g`
  to that), arity 3. **`identity`** `(identity x)` returns `x` unchanged (arity 1). These are the
  building blocks for point-free pipelines with `map`/`filter`.
- **Closures are NOT first-class across module boundaries the way you might expect:** a lambda passed
  to `map`/`fold` is fine, but you cannot store a closure in the DB (only `PactValue`s persist) — to
  persist behaviour use a guard/cap, not a lambda.
- Gas: `map`/`filter`/`fold`/`zip`/`bind`/`compose` flat = basic-work; total ≈ Σ per-element uncons + closure cost.

## Hashing / crypto / ZK — `hash` / `hash-keccak256` / `hash-poseidon` / `base64-*` / `pairing-check`

> Deterministic-hash + ZK primitives underpin principal/event/commitment schemes and drive
> `free.util-zk` (groth16). Verified in `pact/Pact/Core/IR/Eval/CEK/CoreBuiltin.hs`
> (`poseidonHash`/`coreHashKeccak256`/`zkPairingCheck`/`zkScalarMult`/`zkPointAddition`/`coreB64*`),
> `crypto/Pact/Core/Crypto/Pairing.hs` (BN254), and `Keccak256.hs`.

- **`hash` = BLAKE2b-256 over the value's stable encoding → base64url-unpadded string** (the default
  Pact hash; same algorithm as the tx hash). It is deterministic over the canonical `PactValue`
  encoding, so hashing the SAME logical object always matches — but field order / type differences
  change the bytes. Charged by input size.
- **`hash-keccak256` takes a LIST OF STRINGS, each one interpreted as base64url-encoded BYTES**
  `(hash-keccak256 ["b64chunk1" "b64chunk2"])` — every element is base64url-DECODED, the bytes are
  concatenated, keccak256'd, and the result returned as base64url. A non-base64 element fails
  `Base64URL decode failed`. It is NOT "keccak of a UTF-8 string" — passing a raw string fails decode.
- **`hash-poseidon` / `poseidon-hash-hack-a-chain` are the SAME native** — `(hash-poseidon i1 … in)`
  takes **1 to 8 INTEGER field elements** and returns an **integer**. Zero args or >8 args → arity
  error. It is **expensive** (flat gas 124,000) — budget for it. For ZK circuits only.
- **`base64-encode` / `base64-decode` use URL-SAFE, UNPADDED base64** over the UTF-8 string bytes.
  A malformed decode input fails `Decoding error: invalid b64 encoding`. Do not assume standard
  (`+`/`/`/`=`) base64 — it is the URL alphabet, no padding.
- **ZK natives are BN254 (alt-bn128) and validate curve membership.** `(point-add 'g1|'g2 p1 p2)`,
  `(scalar-mult 'g1|'g2 point scalar)` (scalar auto-reduced `mod` the group order),
  `(pairing-check [g1-points] [g2-points])` (→ bool, product of pairings == 1). A **G1 point is the
  object `{ 'x: int, 'y: int }`; a G2 point is `{ 'x: [int int], 'y: [int int] }`**; the point at
  infinity is `{'x:0,'y:0}` (G1). Any point off the curve → fatal `PointNotOnCurve` (not
  `try`-recoverable); for `pairing-check` the G2 points are additionally subgroup-checked (post-Pact 5.4).
- **ZK + poseidon + keccak natives are gated by the `DisablePact51` flag** — `hash-keccak256` /
  `hash-poseidon` and the ZK natives do not resolve when that flag is set (they are Pact 5.1+).
  On KDA-CE assume crypto is always compiled in — `WITHOUT_CRYPTO` builds are not relevant here,
  so do not design around a `crypto disabled` path. *(auditor: Pascal Kda)*
- **`enforce-verifier`** `(enforce-verifier 'name)` checks that a chainweb verifier plugin granted its
  capability (gas 10,000); **`verify-spv`** is the SPV continuation/proof native (gas 100,000) — see
  the cross-chain section for `SPVVerificationFailure`.
- These compose into `free.util-zk`'s groth16 `verify-groth16-proof` (fold of `point-add` over a
  `zip` of `scalar-mult`, then `pairing-check`) — Beta/UNAUDITED; copy-inline, never trust-depend for a security check.

## Defpacts

- **Each `(step ...)` takes exactly ONE expression** — wrap multiple ops in
  `let` / `with-capability`.
- **Lifecycle shape matters**: step 0 runs via `exec`; later progression is via
  continuation (`cont`) state (`pactTxHash`, `step`, `rollback`, optional
  cross-chain proof), not fresh Pact source in the continuation command.
- Defpacts must be called **module-qualified**.
- `continue-pact` across a `commit-tx` needs the **pact-id explicitly**.
- **Rollback legality is constrained**: rollback mode must match a
  `step-with-rollback` boundary, and terminal-step rollback attempts are
  rejected by evaluator continuation checks.

## Source-Anchored Defpact Traps (kda-community/pact-5)

Verified in `pact/Pact/Core/IR/Eval/CEK/Evaluator.hs`,
`pact-repl/Pact/Core/IR/Eval/Direct/Evaluator.hs`,
`pact/Pact/Core/DefPacts/Types.hs`, and static tests:

- Continuation checks are strict and fail with typed errors. Common mismatch /
  lifecycle errors include:
  `DefPactIdMismatch`, `InvalidDefPactStepSupplied`, `DefPactStepMismatch`,
  `DefPactRollbackMismatch`, `DefPactAlreadyCompleted`,
  `NoPreviousDefPactExecutionFound`, `DefPactStepNotInEnvironment`.
- **Only ONE top-level defpact may run per transaction**; starting another while one
  is active fails `MultipleOrNestedDefPactExecFound`. A defpact's `stepCount` is
  discovered at step 0 and fixed for the whole run.
- Nested defpacts must run in **lockstep** with the parent — the child must have the
  **same step count** and the **same rollback shape** as the parent step, advance with
  the `continue` native (NOT `continue-pact`), and be advanced on every parent step.
  Violations: `NestedDefPactParentStepCountMismatch`,
  `NestedDefPactParentRollbackMismatch`, `NestedDefPactNeverStarted`,
  `NestedDefPactDoubleExecution`, `NestedDefpactsNotAdvanced`. The nested pact-id is
  `hash(parentPactId : encodeStable(continuation))`.
- `yield`/`resume` failure modes are explicit, including provenance checks:
  `YieldOutsideDefPact`, `NoActiveDefPactExec`, `NoYieldInDefPactStep`, and
  `YieldProvenanceDoesNotMatch`.
- **Cross-chain yield carries provenance; resume enforces it.** `(yield obj target)`
  stamps `Provenance { targetChainId, callingModuleHash }`; `resume`'s `enforceYield`
  requires the yield provenance to match the resuming module's current hash **or a
  blessed hash** — else `YieldProvenanceDoesNotMatch`. An upgrade between yield and
  cross-chain resume therefore REQUIRES `bless`ing the old module hash.
- **Cross-chain yield is forbidden in a `step-with-rollback`**:
  `EvalError "Cross-chain yield not allowed in step with rollback"` (rollback ⟂ cross-chain).
- **Continuation transport is SPV.** The target-chain `cont` carries an SPV proof;
  `_spvVerifyContinuation` returns the source `DefPactExec`. A bad/missing proof →
  `ContinuationError`; cross-chain consistency may also fail `CCDefPactContinuationError`.
  `verify-spv` is a SEPARATE generic native (platform `_spvSupport`, else
  `SPVVerificationFailure`); both are unsupported under `noSPVSupport`/bare REPL.
- The parser accepts legacy entity step forms (`(step ENTITY EXPR)` and
  `(step-with-rollback ENTITY EXPR ROLLBACK)`) for compatibility, but
  desugaring/eval reject entity-in-defpact usage with
  `EntityNotAllowedInDefPact`.
- `continue-pact` is a REPL helper path (desugared into
  `RContinuePact*` variants), not an on-chain native for module code.

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

## Pact 4→5 migration traps (upgrading pre-2025 code)

> Source: official migration guide (kadena-docs `smart-contracts/install/migrate-pact5.md`).
> Mainnet switched to Pact 5 on 2025-02-10. Anything older — most tutorials, blog posts,
> and forum answers — is Pact 4 material and can mislead on the points below.

- **Module hashes now include dependency hashes (transitive).** Same module source ≠ same
  hash once any dependency changed (Pact 4 hashed only your source). Consequence: `bless`
  lists and cross-chain yield-provenance planning must account for hash changes caused by
  DEPENDENCY upgrades, not just your own edits.
- **No implicit module-admin acquisition** (except during module upgrade itself). Pact 4
  auto-granted admin when outside code wrote a module's table or acquired its caps; Pact 5
  requires explicit `(acquire-module-admin m)` — semantics in the Modules section.
- **`install-capability` is strict**: duplicate installs and non-`@managed` targets are hard
  errors (Pact 4 silently allowed both; duplicates kept the lexicographically smallest
  managed param). Fix: delete manual `install-capability` calls for signed-for caps —
  a matching signature installs a managed cap implicitly. Error strings: Capabilities
  section + the error-string table.
- **Integer JSON codec is strict**: command results always encode integers as `{"int": N}`;
  a raw JSON number is a DOUBLE. Pact 4 silently converted integers to doubles in results —
  TypeScript written against Pact 4 output can mis-parse Pact 5 results.
- **Gas-cap signing is strict**: sign `(coin.GAS)` with NO arguments. Pact 4 accepted
  `(coin.GAS "")` / `(coin.GAS 1)`; Pact 5 rejects extra args at signature scoping.
- **Removed natives**: `list` (write `[1 2 3]`), `txlog`, `decrypt-cc20p1305`,
  `validate-keypair`. **`constantly` now takes exactly 2 args.** `pact-version` /
  `enforce-pact-version` survive as REPL-ONLY builtins (the migration guide says removed,
  but they exist in 5.4 source as repl natives — never call them from module code).
- **Parser is strict** — Pact 4 parser bugs let all of these deploy; Pact 5 rejects at load:
  - one expression per `let` binding — `(let ((x 1 (f))) …)` no longer parses;
  - object types are `object{schema}` — `object:{schema}` is invalid;
  - binding lists need commas: `{ "a" := a, "b" := b }`;
  - schema names are not values — the classic `(read <schema-name> k)` table/schema mixup
    is now a load-time error (`Invalid definition in term variable position`).
- **`static-redeploy` is the free storage upgrade**: `(static-redeploy "ns.mod")` re-stores
  a legacy module in the Pact 5 CBOR format — cheaper loads, hash unchanged, governance
  unchanged, and UNPRIVILEGED (anyone can call it on any module).
- The other two big 4→5 breaks have their own sections: **native shadowing ban**
  (`Native/built-in name shadowing`) and **no `verify` native / no FV system**
  (`Pact 5 version notes`).

## Pact 5 version notes

- **5.0** — `let` ≡ `let*`; gas model revamp.
- **5.1** — native shadowing checks (`--check-shadowing`); CLI **exits non-zero on
  REPL test failure** (wire into CI).
- **5.2** — `typecheck` native added.
- **5.3** — read-only modref reentrancy guard; `enforce` / user-guards run
  read-only; coverage support.
- **5.4ce** — KDA-CE fork of kadena-io/pact-5. No documented functional language changes vs 5.3. **KDA-CE target.**

## Reusable error strings: REPL vs. on-chain rendering

**Pact 5 has TWO error-rendering paths producing different text:**

- **REPL / `expect-failure` (`.repl` tests)** → `renderCompactText` via `coreExpectFailure` in `pact-repl/Pact/Core/IR/Eval/Direct/ReplBuiltin.hs`, delegates to the per-error `Pretty` instances in `pact/Pact/Core/Errors.hs` (`instance Pretty (PactError info)`, `instance Pretty DbOpError`, `instance Pretty UserRecoverableError`, `instance Pretty EvalError`, `instance Pretty DesugarError`).
- **On-chain / devnet (TypeScript error-substring matching)** → `pactErrorToOnChainError` → `pactErrorToBoundedText` and related `*ToBoundedText` functions in `pact/Pact/Core/Errors.hs` (`dbOpErrorToBoundedText'`, `userRecoverableErrorToBoundedText`, `evalErrorToBoundedText`, `desugarErrorToBoundedText`); these are replay-stable and bounded.

**Rule:** In `.repl` `expect-failure`, match the REPL (Pretty) column. In devnet TypeScript error assertions, match the on-chain (BoundedText) column.

| Trigger | REPL `expect-failure` substring (Pretty instance) | On-chain / devnet substring (BoundedText) |
|---|---|---|
| DML (insert/update/write) inside `enforce` arg or `try` | `Operation disallowed in read-only or sys-only mode` | `Operation is not allowed in read-only or system-only mode.` |
| table READ inside an `enforce` condition | *(passes in the REPL — no error; REPL-invisible)* | `Operation is not allowed in read-only or system-only mode.` |
| `insert` on existing key | `Value already found while in Insert mode` | `Insert failed because the value already exists in the table:` |
| `update` on a missing key | `No row found during update in table` | `Update failed because no row was found in table:` |
| write object doesn't match table schema | `Attempted insert failed due to schema mismatch. Expected:` | `Insert failed because of a schema mismatch with` |
| `read` on missing key | `No value found in table` … `for key:` | `No value found in table` … `for key:` |
| bound a field missing from object/default; `at`/`where` on a missing object field | `Key "X" not found in object` | `Key X not found in object.` |
| failed keyset enforcement | `Keyset failure (` | `Keyset failure (` |
| `keyset-ref-guard` / enforce of an undefined keyset | `Cannot find keyset in database:` | `Cannot find keyset in the database:` |
| `define-keyset` namespace mismatch | `Error defining keyset, namespace mismatch, expected` | `Defining keyset failed because of a namespace mismatch. Expected namespace:` |
| `define-keyset` outside a namespace (ns required) | `Cannot define keyset outside of a namespace` | `Cannot define keyset outside of a namespace.` |
| `(namespace "x")` where x is not defined | `Namespace not found:` | `Namespace not found:` |
| module/interface install in root when policy forbids | `Namespace installation error: cannot install in root namespace` | `Namespace installation failed. Cannot install modules in the root namespace.` |
| `define-namespace` with a bad name / policy-denied | `invalid namespace format` / `Namespace definition not permitted` | `invalid namespace format` / `Namespace definition not permitted` |
| `read-keyset` with `EnforceKeyFormats` + bad key | `Invalid keyset format:` | `Invalid keyset format. Check that keys have the right length and signature scheme.` |
| division by zero | `Arithmetic exception:` | `Arithmetic exception:` |
| `(sqrt <neg>)` / `(ln <=0)` domain error | `Arithmetic exception:` | `Arithmetic exception:` |
| int `^` with negative exponent | `Arithmetic exception: negative exponent in integer power` | `Arithmetic exception: negative exponent in integer power` |
| transcendental NaN/∞ result | `Floating point error:` | `Floating point error:` |
| decimal literal ≥255 places (parse) | `Precision overflow (>=255 decimal places)` | `Precision overflow (>=255 decimal places):` |
| `read-*` missing key / wrong type (recoverable; `try`-catchable) | `read-integer failure` (per-native: `read-string failure`, …) | `read-integer failed. Invalid format or missing key.` (per-native) |
| `require-capability` not in scope | `require-capability: not granted` | `The required capability has not been granted:` |
| `emit-event` on a plain (non-`@event`/`@managed`) cap | `Invalid event capability` | `Invalid event capability:` |
| `emit-event` of a cap from outside its owning module | `Emitted event does not match module:` | `Emitted event does not match module:` |
| `install-capability` on a non-managed cap | `Install capability error: capability is not managed and cannot be installed:` | `Install capability failed. Capability is not declared as a managed capability and cannot be installed.` |
| managed-cap `with-capability` without install/sig | `Managed capability not installed:` | `Managed capability` … `was not installed.` |
| duplicate `install-capability` | `Capability already installed:` | `Capability` … `already installed.` |
| one-shot/auto-managed cap reused | `One-shot managed capability used more than once` | `Managed capabilities can only be used once.` |
| `enforce-guard` of a capability guard whose cap is not in scope | `Capability not acquired:` | `Capability not acquired:` |
| capability pact guard enforced with wrong/absent pact-id | `Capability pact guard failed: invalid pact id, expected` | `Pact guard failed because of an invalid pact id. Expected:` |
| external / top-level `with-capability` of a module's own cap | `Module admin necessary for operation but has not been acquired` | `Module admin is necessary for operation but has not been acquired:` |
| cross-module call to an unblessed old module hash | `Execution aborted, hash not blessed for module` | `Execution aborted, hash not blessed for module:` |
| `bless` with a malformed hash literal (load-time) | `Invalid blessed hash, incorrect format:` | `Invalid blessed hash, incorrect format:` |
| `(pact-id)` outside a defpact | `Attempted to fetch defpact data, but currently not within defpact execution` | `Attempt to fetch defpact data failed because there's no defpact currently being executed.` |
| cross-chain resume provenance mismatch (unblessed upgrade) | `Yield provenance does not match, received` | `Yield provenance does not match, received:` |
| cross-chain yield inside a `step-with-rollback` | `Cross-chain yield not allowed in step with rollback` | `Cross-chain yield not allowed in step with rollback` |
| SPV / continuation proof failure | `SPV verification failure:` / `Continuation Error:` | `SPV verification failure:` / `Continuation error:` |
| `at` list index out of bounds (fatal, not `try`-catchable) | `Array index out of bounds. Length` | `Array index out of bounds. Length:` |
| `enumerate` 3-arg step diverges from bounds | `Enumeration error:` | `Enumeration error:` |
| native execution error (`format` too few args, `int-to-str` negative, …) | `native execution failure,` … `failed with message:` | `Native execution failed for` … `with the message:` |
| `(time s)` with non-ISO8601 / malformed string | `native execution failure,` … `time default format parse failure` | `Native execution failed for` … `time default format parse failure` |
| `(parse-time fmt s)` string doesn't match format | `native execution failure,` … `parse-time parse failure` | `Native execution failed for` … `parse-time parse failure` |
| `(is-charset <id> s)` with unsupported charset id (not 0/1) | `native execution failure,` … `Unsupported character set` | `Native execution failed for` … `Unsupported character set` |
| ZK point off the curve (`point-add`/`scalar-mult`/`pairing-check`; fatal) | `Point lies outside of elliptic curve` | `Point lies outside of the elliptic curve.` |
| `hash-keccak256` element not valid base64url | `Base64URL decode failed` | `Base64URL decode failed` |
| crypto native on a no-crypto build / bare REPL | `crypto disabled` | `crypto disabled` |
| `(+ 1 2 3)` / arity error | `Attempted to apply a closure to too many arguments` | `Failed to apply a function or closure because there were too many arguments.` |
| binding a native name (load-time) | `shadows native with the same name` | `shadows native with same name` |
