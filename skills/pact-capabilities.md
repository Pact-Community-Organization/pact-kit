---
name: pact-capabilities
description: "Pact 5 capability patterns — @managed, @event, compose-capability, install-capability, capability guards, and access control for smart contracts."
---
# Pact Capabilities

> Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md). This skill explains capability mechanics; it does not re-list traps.

## Capability Types

### Unmanaged (Boolean Guard)
```pact
(defcap ADMIN ()
  (enforce-guard (keyset-ref-guard "admin-keyset")))
```

### Managed (@managed)
```pact
(defcap TRANSFER (sender:string receiver:string amount:decimal)
  @managed amount TRANSFER-mgr
  (enforce-guard (at 'guard (read accounts sender))))

(defun TRANSFER-mgr:decimal (managed:decimal requested:decimal)
  (let ((remaining (- managed requested)))
    (enforce (>= remaining 0.0) "TRANSFER exceeded")
    remaining))
```

### Event-Only (@event)
```pact
(defcap TRANSFER-EVENT (sender:string receiver:string amount:decimal)
  @event true)
```

## with-capability vs require-capability

These are NOT interchangeable. Choosing wrong either re-runs a guard you didn't
mean to re-run, or silently grants access.

Error-surface note: when matching failure text, keep rendering context explicit.
REPL `.repl` failures use Pretty strings, while on-chain/devnet failures use
BoundedText. Use the canonical mapping table in
[../instructions/pact-traps.md](../instructions/pact-traps.md)
instead of mixing surfaces.

### `with-capability` — acquire and scope a grant
- Evaluates the defcap predicate **exactly ONCE**, then runs its body in a scope
  where the cap is granted. Use it at the boundary where authorization happens.
- If the cap is **already in scope**, `with-capability` does **NOT** re-evaluate
  the predicate — it just runs the body. So re-entering `with-capability` for an
  already-granted cap is cheap and side-effect-free on the guard.

```pact
(defun transfer (from:string to:string amount:decimal)
  (with-capability (TRANSFER from to amount)   ; guard runs ONCE here
    (debit from amount)                        ; internal
    (credit to amount)))                       ; internal
```

### `require-capability` — assert an already-granted cap
- Asserts a cap is **already in scope**. It does **NOT** evaluate the predicate
  and does **NOT** scope a body. If the cap is not granted, matching error text
  differs by context (REPL Pretty vs on-chain BoundedText; see canonical traps).
- **Position matters: put it at the TOP of the function.** This is the canonical
  pattern for private/internal functions (`debit`/`credit`) — they must only be
  reachable from inside the public function that already acquired the cap.

```pact
(defun debit (acct:string amount:decimal)   ; PRIVATE — never call directly
  (require-capability (TRANSFER acct "" amount))   ; assert, no re-eval, top of fn
  (update accounts acct { "balance": (- ...) }))
```

The debit/credit pattern: a public `transfer` does `with-capability (TRANSFER …)`
once; the internal `debit`/`credit` each start with `require-capability`. An
external caller cannot invoke `debit` directly because the cap is not in scope.

## compose-capability

- `compose-capability` brings an inner cap into scope **only WHILE the parent
  cap is granted** — the inner grant is torn down when the parent scope exits.
- **`compose-capability` is callable ONLY from within a defcap body.** The
  evaluator runs `enforceStackTopIsDefcap` before composing, so calling
  `compose-capability` outside a `defcap` (e.g. in a `defun`) is a hard error.
  Source: `composeCapability` in `pact/Pact/Core/IR/Eval/CEK/CoreBuiltin.hs`.
- In this workspace/toolchain, **foreign compose has been observed**. Treat
  cross-module composition as a potential privilege path and audit callers,
  call order, and cap boundaries carefully.
- **VERIFIED: the composed cap's predicate body is evaluated EAGERLY at
  acquisition** of the parent. Do NOT put a `require-capability` for a
  not-yet-granted dependency inside a composed cap — it will fail at the moment
  the parent acquires, not later. Source anchor:
  `pact/Pact/Core/IR/Eval/CEK/CoreBuiltin.hs` (`composeCapability` -> `composeCap`)
  and `pact/Pact/Core/IR/Eval/CEK/Evaluator.hs` (cap evaluation path).

```pact
(defcap MINT (acct:string amount:decimal)
  (compose-capability (CREDIT acct))   ; CREDIT body runs eagerly now
  (enforce-guard (keyset-ref-guard "minter")))
```

## Weak-body & `true`-body capabilities — the permission-token model

A `defcap` body is **not a public ACL**. A capability can only be *acquired*
(`with-capability`) by code **inside the module that declares it**. External
callers, top-level tx code, and other modules can never grant a module's cap.

VERIFIED — a direct external/foreign-module attempt to acquire a module's cap
fails because module-admin acquisition is required for that module. Use canonical
trap strings for exact REPL/on-chain wording.

Caveat: cross-module `compose-capability` may still pull a foreign cap into
scope and eagerly evaluate its body during parent acquisition. Treat weak/`true`
foreign caps as audit-sensitive if they can be reached through composition.

**Consequence:** a `true`/weak body cap is an **in-module permission token**, not
an authorization check. Security = **WHO can reach the `with-capability` site**,
not what the body says. `require-capability` only checks *scope* — it does **not**
evaluate the cap body — so the functions it guards become **private functions**
reachable only via the module's own (real-guarded) acquisition path.

> VERIFIED behavior summary: `with-capability` performs acquisition-time cap-body
> evaluation, while `require-capability` checks only scope membership (it does not
> re-run cap bodies). Use canonical traps for exact failure-string matching.

### coin capability classification (coin module example, not a universal Pact rule)

| Cap | Body | Real guard? | Why safe |
|-----|------|-------------|----------|
| `GOVERNANCE` | `(enforce false "Enforce non-upgradeability")` | N/A (deny-all) | Un-acquirable ⇒ module is immutable. `false` is the correct sentinel. |
| `DEBIT` | `(enforce-guard (at 'guard (read coin-table sender)))` + `(enforce (!= sender ""))` | ✅ YES | This *is* the money-out authorization (sender must sign). |
| `CREDIT` | `(enforce (!= receiver "") "valid receiver")` | ❌ WEAK | Private via `require-capability`; only acquired composed under `DEBIT` inside managed `TRANSFER`; always paired with a preceding `debit` (mass-conserving). |
| `ROTATE` | `@managed` + `true` | ✅ (real guard is *inside* `rotate`: `enforce-guard old-guard`) | One-shot managed + in-fn guard. |
| `TRANSFER` | `@managed amount TRANSFER-mgr`, composes `(DEBIT sender)`+`(CREDIT receiver)` | ✅ (via composed `DEBIT`) | Scoped/managed signature + real guard pulled in by composition. |
| `TRANSFER_XCHAIN` | `@managed amount TRANSFER_XCHAIN-mgr` (one-shot), composes `(DEBIT sender)` | ✅ (via composed `DEBIT`) | Cross-chain send; one-shot managed cap — cap exhausted after a single transfer. |
| `TRANSFER_XCHAIN_RECD` | `@event` only | — | Emitted on the receiving chain in step 2 of `transfer-crosschain`. No predicate body. |
| `GAS` / `COINBASE` / `GENESIS` / `REMEDIATE` | `true` | ❌ none | "Magic" caps installed **only** by the node's execution machinery on specific protocol paths; consumed via `require-capability`. Presence of the cap *is* the proof of context (Pact 5.2 magic capabilities). |

### Why coin `CREDIT` is a SAFE weak cap (coin-specific example)

Crediting is **not privileged** — anyone may receive funds. Minting-from-nothing
is prevented **structurally**, not by the `CREDIT` body:

1. `credit` is private — it begins with `(require-capability (CREDIT account))`.
2. The only in-module acquisition of `CREDIT` is **composed under** the
   real-guarded `DEBIT` inside managed `TRANSFER`, always **paired with a
   preceding `debit`** (mass-conserving).
3. It is formally backed by
   `@model (defproperty conserves-mass (= (column-delta coin-table 'balance) 0.0))`.

```pact
(with-capability (TRANSFER sender receiver amount) ; composes DEBIT(enforce-guard)+CREDIT
  (debit  sender amount)                           ; DEBIT in scope → sender signed
  (credit receiver g amount))                      ; CREDIT in scope → ok, paired
```
No sender signature ⇒ no `DEBIT` ⇒ no `TRANSFER` ⇒ `CREDIT` never in scope ⇒
`credit` is unreachable. (Wrong signer on the happy path fails at `DEBIT` with
`Keyset failure (keys-all)` — `CREDIT` being weak never matters because
authorization is enforced on the way *in*.)

### Safe coin `CREDIT` vs unsafe YODA6 `USER` (side-by-side)

```pact
; SAFE — weak CREDIT is never the outermost gate on a public path.
; credit is private; CREDIT only enters scope composed under real-guarded DEBIT.
(defcap CREDIT (receiver:string) (enforce (!= receiver "") "valid receiver"))
(defun credit (account guard amount)
  (require-capability (CREDIT account))   ; private — direct call fails
  ...)
```
```pact
; UNSAFE (YODA6) — a PUBLIC defun acquires the weak cap as the sole gate,
; so the weak body IS the authorization. Any non-empty account passes.
(defcap USER (account:string) (enforce (!= account "") "Specify an account"))
(defun hello-world (input account)
  (with-capability (USER account)         ; public wrapper acquires weak cap
    (format "Hello {}" [input])))         ; → anyone "authenticates"
```
The danger is **exposing `with-capability` of a weak cap through an unguarded
public path** — not the `true`/weak body itself.

> Auditing weak-body caps (the SAFE-vs-EXPLOITABLE rule + grep heuristic):
> [../skills/capability-analysis.md](../skills/capability-analysis.md).
> Conservation backing (`conserves-mass`):
> [../skills/formal-verification.md](../skills/formal-verification.md).

## Managed Capabilities — manager function contract

`@managed res mgr-fn` makes a cap manage a depletable **resource**. The manager
function has the shape `(managed:T requested:T) -> T:newManaged` and runs on each
acquisition. It **MUST**:

1. **Subtract** the requested amount from the managed balance.
2. **Enforce non-negative** (`(enforce (>= remaining 0.0) "...")`).
3. **RETURN the decremented value** (the new managed balance is threaded forward).

```pact
(defun TRANSFER-mgr:decimal (managed:decimal requested:decimal)
  (let ((remaining (- managed requested)))      ; (1) subtract
    (enforce (>= remaining 0.0) "TRANSFER exceeded")  ; (2) non-negative
    remaining))                                 ; (3) RETURN decremented
```

### Manager-function bug variants (audit these)
- **Returns `managed` unchanged** → the allowance never depletes →
  **unlimited reuse** within the granted scope.
- **Omits the `>= 0` enforce** → **overspend**; balance goes negative.
- **Returns `requested`** instead of `remaining` → nonsense threading.

### `@managed` with NO manager = single-use
A defcap with bare `@managed` (no resource/manager) can be acquired **at most
once per transaction**. Ideal for **VOTE** — one signature, one vote, replay-safe.

```pact
(defcap VOTE (voter:string proposal:string)
  @managed                       ; single-use this tx
  (enforce-guard (at 'guard (read accounts voter))))
```

### Reference: coin contract
`coin.TRANSFER` uses `@managed amount TRANSFER-mgr`; `TRANSFER-mgr` subtracts,
enforces `>= 0.0`, and returns the remainder — the canonical **decremental** pattern.

`coin.TRANSFER_XCHAIN` (fungible-xchain-v1) uses `@managed amount TRANSFER_XCHAIN-mgr`;
`TRANSFER_XCHAIN-mgr` enforces `requested <= managed` and returns **`0.0`** — the
canonical **one-shot** pattern. Do NOT apply the decremental pattern to cross-chain
manager functions.

## Managed capabilities and signatures

For managed-cap flows, the critical evaluator rule is installation before use:
`with-capability` on a managed cap fails if the capability is not installed
(typically via scoped signatures in `env-sigs` or via `install-capability`).
This is the source-backed replay-safety mechanism to enforce explicit cap
provisioning.

### Scoped signatures
- Sign with a **clist** (`env-sigs` in REPL) scoping the key to specific caps:
  ```pact
  (env-sigs [{ "key": "alice-key",
               "caps": [(coin.TRANSFER "alice" "bob" 5.0)] }])
  ```
- The scoped cap's **arguments must match** the cap actually acquired. Changing
  an arg (different amount/receiver) → **keyset failure** at acquisition. This is
  what binds a signature to an exact action.

## install-capability scoping

`install-capability` for a `@managed` cap is constrained by evaluator checks,
not by a hard "inside owning `with-capability`" rule. The hard checks are:
not callable within a defcap body (`FormIllegalWithinDefcap` via
`enforceNotWithinDefcap`), valid managed metadata target (`InvalidManagedCap` —
plain/`@event` caps cannot be installed), and no duplicate install for the same
managed token in scope (`CapAlreadyInstalled`). On success it returns the string
`"Installed capability"`. Source: `installCapability` / `installCap` in
`pact/Pact/Core/IR/Eval/CEK/CoreBuiltin.hs` and `Evaluator.hs`. See canonical traps.

## Where capabilities can be acquired

- **You CANNOT acquire a cap inside a defcap body.** Calling `with-capability`
  inside a `defcap` is rejected as a defcap-illegal form. Use
  **`compose-capability`** to
  pull in a dependency cap from within a defcap instead.
- **Direct foreign `with-capability` is blocked** in verified behavior, but
  cross-module composition may still be possible in this workspace/toolchain.
  Audit cross-module compose paths as privilege surfaces, and never bring a cap
  into scope before a cross-module / module-reference call
  (privilege-escalation surface — see cross-module-rules).

## Events

`@managed` caps **and** `@event` caps **auto-emit** an on-chain event on
acquisition. Do **not** add an explicit `emit-event` for them (double-emit). See
the pact-events skill for event payload conventions.

## Quick Rules
1. `with-capability` = acquire + scope + run-guard-once; `require-capability` =
   assert-already-granted, no body, top of internal fns.
2. Manager fn — two distinct contracts: **decremental** (TRANSFER-mgr: subtract → enforce `>= 0` → return remainder) vs **one-shot** (TRANSFER_XCHAIN-mgr: enforce `requested <= managed` → return `0.0`). Do not conflate.
3. Bare `@managed` = single-use per tx (VOTE).
4. Managed caps must be explicitly installed before acquisition (scoped sigs or
  `install-capability`).
5. No `with-capability` inside a defcap — compose instead.
6. `install-capability` is validated by evaluator constraints (not-in-defcap,
   valid managed metadata, no duplicate install).
