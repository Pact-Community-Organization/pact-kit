---
name: pact-guards
description: "Pact 5 guard taxonomy: keyset/keyset-ref/user/capability guards, principal k:/w:/r:/u:/c: prefixes, enforce-guard semantics, and the escrow pattern."
---
# Pact Guards & Principals

> Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md)

## Guard Taxonomy
| Guard | Create / use | Principal prefix | Notes |
|-------|--------------|------------------|-------|
| Keyset guard | `read-keyset` / `define-keyset` / `enforce-keyset` | `k:` single-key, `w:` multi-key | Inline or named keyset; set-based |
| KeysetRef guard | `(keyset-ref-guard "ns.name")` | `r:` | Reference to a named keyset by string |
| User guard | `(create-user-guard (top-level-fn args))` | `u:` | Evaluated in read-only context: DB reads allowed, DB writes disallowed |
| Capability guard | `(create-capability-guard (CAP))` | `c:` | Use when the guard needs DB state |
| Capability pact guard | `(create-capability-pact-guard (CAP))` | `c:` | Like a cap guard but binds the current `pact-id`; only the same defpact can satisfy it (escrow). NOT deprecated. |
| Module guard | legacy only | `m:` (legacy) | Deprecated as unsafe; avoid new usage |
| Pact guard | legacy only | `p:` (legacy) | Deprecated as unsafe; avoid new usage |

### User guard vs Capability guard
A **user guard** predicate is evaluated in a read-only context: it can perform reads, but it cannot perform DB writes. If your guard logic needs authority-scoped state checks and privileged flow control, use a **capability guard** and place that logic in the capability body.

Construction note: write user guards as top-level function applications (for example `(create-user-guard (my-predicate arg))`); do not rely on arbitrary closure capture semantics.

For exact REPL vs on-chain error substrings, use the canonical traps doc rather than hardcoding strings in this skill.

```pact
;; ❌ user guard cannot perform DB writes
;; ✅ capability guard CAN gate privileged flows on DB state
(defcap WITHDRAW (account:string)
  (enforce-guard (at 'guard (read accounts account))))

(create-capability-guard (WITHDRAW "alice"))
```

### Capability pact guard (escrow pattern)
`(create-capability-pact-guard (CAP))` produces a `c:` capability guard that
**also captures the current `pact-id`**. The guard is satisfiable only when the
SAME defpact (matching pact-id) has `CAP` in scope — the canonical Marmalade
escrow pattern: the escrow account is
`(create-principal (create-capability-pact-guard (SALE_PRIVATE (pact-id))))`, so
only the sale defpact's own steps can debit it. Enforcing it with a wrong/absent
pact-id fails `CapabilityPactGuardInvalidPactId`; enforcing a plain capability
guard whose cap is not in scope fails `CapabilityGuardNotAcquired` (see canonical
traps for exact strings). This is distinct from the **deprecated**
`create-pact-guard` (`p:`), which only stores a pact-id+name with no capability.

## Keyset Predicates
- `keys-all` — every key in the set must sign.
- `keys-any` — at least one key must sign.
- `keys-2` — at least two keys must sign.
- **Custom predicate** — a 0-arg-free reference to a **`defun` OR a native** taking
  `(count:integer matched:integer) -> bool` (count = keys in set, matched = signing
  keys present). A non-defun/non-native ref fails `InvalidCustomKeysetPredicate`.
- Keysets are **set-based / order-independent**.
- **Key formats:** ed25519 = exactly **64 lowercase hex** chars; WebAuthn = `WEBAUTHN-`
  prefixed. Validation only runs when the `FlagEnforceKeyFormats` exec flag is set
  (`read-keyset` then fails `InvalidKeysetFormat`).

## Guard Enforcement — `enforce-guard` ≡ `enforce-keyset`
`enforce-keyset` and `enforce-guard` are the **same operation** (Semantics.md:
"basically they're an alias"); both have type `EnforceRead a => a -> bool` where `a`
is **either a `guard` or a keyset-name `string`** — a string is interpreted as a
keyset-ref. `enforce-guard` dispatches by guard kind (`enforceGuard` in the evaluator):
- **keyset** → `isKeysetInSigs`: filter tx sigs to the keyset's keys, apply
  `checkSigCaps` (scoped-signature filtering), then run the predicate. Failure →
  `KeysetPredicateFailure` ("Keyset failure (pred): keys").
- **keyset-ref** (`'name` / `ns.name`) → read the keyset from the DB (missing →
  `NoSuchKeySet`), then as above.
- **user guard** → run its predicate **read-only** (DB reads allowed, writes fail).
- **capability guard** → succeeds only if the cap is currently in scope
  (`CapabilityGuardNotAcquired` otherwise); a capability-**pact**-guard additionally
  checks the current `pact-id` (`CapabilityPactGuardInvalidPactId`).
- **module guard** → DEPRECATED: emits a `ModuleGuardEnforceDetected` warning, then
  passes only if called by that module or after acquiring its module admin.

**`enforce-guard` returns `true` or aborts the tx** — it never returns `false`.

## define-keyset & rotation
`define-keyset` is **top-level only** (`enforceTopLevelOnly`). Two forms:
`(define-keyset name keyset)` and `(define-keyset name)` (reads `name` from tx data,
like `read-keyset`; a missing/invalid payload fails the read).
- **Rotation auth:** if the keyset name **already exists**, the **existing keyset is
  enforced** (via a magic `DEFINE_KEYSET` cap) **before** it is overwritten — only the
  current keyset holders can rotate it.
- **Namespacing:** when `FlagRequireKeysetNs` is set, a brand-new keyset must be defined
  **inside a namespace**, and the keyset name's namespace must match the active
  namespace — else `MismatchingKeysetNamespace`; defining with no active namespace fails
  `CannotDefineKeysetOutsideNamespace`.

## Principal Accounts
Built-ins: `create-principal`, `validate-principal`, `is-principal`, `typeof-principal`.

- **`validate-principal` is NOT an auth check** — `(validate-principal guard account)` only confirms `account` is the canonical principal string for `guard` (a string compare); it does NOT prove the caller satisfies the guard. Always pair it with `(enforce-guard guard)` for authorization. See canonical traps.
- **`is-principal` / `typeof-principal` check format only** — they never throw; `typeof-principal` returns the prefix (`k:`/`w:`/`r:`/`u:`/`m:`/`p:`/`c:`) or `""` for a non-principal. Neither proves the guard is satisfiable.

> `read-keyset 'k` reads a keyset **literal** from tx data and returns a keyset guard.
> `keyset-ref-guard "name"` returns a **reference** (`r:`) to a keyset previously stored
> via `define-keyset` (missing → `NoSuchKeySet`). Use `read-keyset` for inline keysets,
> `keyset-ref-guard` to store a reference alongside other guards in a column.

Legacy principal formats still exist for deprecated guard families:
- `m:` corresponds to module guards (deprecated family).
- `p:` corresponds to pact guards (deprecated family).
- Keep these for legacy interpretation only; do not introduce new usage.

**VERIFIED format gotcha:**
- `k:<pubkey>` is produced **ONLY** for a guard that is a single valid 64-hex ed25519 key with the `keys-all` predicate.
- Multi-key, non-`keys-all`, or invalid-key guards produce `w:<hash>:<pred>`.

```pact
;; Module-owned account pattern
(defcap VAULT_GUARD () true)
(defconst VAULT_GUARD_G:guard (create-capability-guard (VAULT_GUARD)))
(defconst VAULT_ACCT:string (create-principal VAULT_GUARD_G))   ;; "c:..."
```

### coin.enforce-reserved pattern
Reserved/principal accounts enforce that the account name matches its guard (single-key `k:` protocol): the `k:`-prefixed pubkey must equal the guard's single key. Use `validate-principal` to assert an account string corresponds to a given guard before crediting.

### Row-level keysets
Store a `guard` in a column and enforce it on read/write:

```pact
(defschema account guard:guard balance:decimal)
(defun withdraw (acct:string amt:decimal)
  (enforce-guard (at 'guard (read accounts acct)))   ;; row-level guard
  (update accounts acct { "balance": (- (at 'balance (read accounts acct)) amt) }))
```

## Guards vs Capabilities
- **Guard** = a pass/fail predicate. Testable anywhere (even outside a module), grants **no** privilege by itself.
- **Capability** = grants authority, and only **inside the declaring module** for the dynamic extent of `with-capability`.
- Use guards to authenticate *who*; use capabilities to authorize *what* and to scope privilege. See canonical traps for `pact-id` and capability-scope pitfalls.
