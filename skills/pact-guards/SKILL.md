---
name: pact-guards
description: "Pact 5 guard taxonomy and principal accounts — keyset, keyset-ref, user, capability guards, principal create/validate, k:/w:/r:/u:/c: prefixes, and guards-vs-capabilities for KDA-CE."
---
# Pact Guards & Principals

> Canonical traps: [.github/instructions/pact-traps.instructions.md](../../instructions/pact-traps.instructions.md)

## Guard Taxonomy
| Guard | Create / use | Principal prefix | Notes |
|-------|--------------|------------------|-------|
| Keyset guard | `read-keyset` / `define-keyset` / `enforce-keyset` | `k:` single-key, `w:` multi-key | Inline or named keyset; set-based |
| KeysetRef guard | `(keyset-ref-guard "ns.name")` | `r:` | Reference to a named keyset by string |
| User guard | `(create-user-guard (fn args))` | `u:` | Arbitrary **PURE** predicate — **NO DB access** during evaluation |
| Capability guard | `(create-capability-guard (CAP))` | `c:` | Use when the guard needs DB state |
| Module guard | — | — | **DEPRECATED as unsafe — do not use** |
| Pact guard | — | — | **DEPRECATED as unsafe — do not use** |

### User guard vs Capability guard
A **user guard** predicate is evaluated in a pure context — it **cannot read a table**. If your guard logic must read DB state, use a **capability guard** instead, and put the DB-reading logic inside the capability body.

```pact
;; ❌ user guard cannot read a table
;; ✅ capability guard CAN gate on DB state
(defcap WITHDRAW (account:string)
  (enforce-guard (at 'guard (read accounts account))))

(create-capability-guard (WITHDRAW "alice"))
```

## Keyset Predicates
- `keys-all` — every key in the set must sign.
- `keys-any` — at least one key must sign.
- `keys-2` — at least two keys must sign.
- Custom predicates — fully-qualified function names.
- Keysets are **set-based / order-independent**.

## Principal Accounts
Built-ins: `create-principal`, `validate-principal`, `is-principal`, `typeof-principal`.

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
