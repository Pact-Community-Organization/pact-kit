---
name: pact-schema-design
description: "Pact 5 schema and table design — field types, key patterns, deftable/create-table ordering, with-default-read migrations, tombstone deletes, and select/keys local-only constraints for KDA-CE."
---
# Pact Schema Design

> Canonical traps: [.github/instructions/pact-traps.instructions.md](../../instructions/pact-traps.instructions.md)

## Schema & Table Definition
```pact
(defschema my-schema
  @doc "Schema description"
  field1:string
  field2:integer
  field3:decimal
  field4:bool
  field5:guard
  field6:time)

(deftable my-table:{my-schema})
```
- **Schema name ≠ table name** — they are distinct identifiers; keep them different (e.g. `account` schema, `accounts` table).
- **`create-table` runs AFTER the module** is defined, not inside it.
- **Field types are enforced at runtime** on write — a type mismatch fails the tx.

```pact
(module my-module GOVERNANCE
  ;; ... defschema / deftable / defuns ...
)
(create-table my-table)   ;; AFTER the module form
```

## Field Types
- `string` — text, account names, identifiers
- `integer` — whole numbers, counts
- `decimal` — monetary values, ratios (arbitrary precision)
- `bool` — flags, status
- `guard` — access control (keyset, keyset-ref, user, capability guards)
- `time` — timestamps
- `[type]` — lists (e.g. `[string]`)
- `object{schema}` — nested objects

## Key Strategies
| Pattern | Key Format | Example |
|---------|-----------|---------|
| Account | account name | `"k:abc123..."` |
| Singleton config | constant string | `"config"` |
| Composite / indexed | formatted string | `(format "{}-{}" [voter proposal-id])` |
| Sequential | counter-based | `(int-to-str 10 next-id)` |

Notes:
- Account tables key on the account name (string).
- Config tables key on a fixed constant (e.g. `"config"`).
- Indexed tables key on a composite string.

## No NULLs, No Deletes
- Pact rows have **no NULLs** — every bound field must have a value.
- There is **no row delete** — use an `active:bool` **tombstone** column and filter on it.

```pact
(defschema member active:bool name:string)
;; "delete" = deactivate
(defun deactivate (k:string)
  (update members k { "active": false }))
```

## Schema Evolution & Migration
- **There is NO in-place schema migration on module upgrade.** You cannot change an existing table's schema.
- To evolve: **define a NEW table with the new schema, then read-old / write-new** in a migration function.
- `with-default-read` covers reads of rows that predate a newly-bound field. **The default object must contain every field you BIND**, not every schema field (see canonical traps).
- Never reuse a field name with a different type; defaults must be safe (not exploitable zeros).

```pact
;; Safe read of pre-existing rows
(with-default-read my-table key
  { "new-field": "safe-default" }     ;; only the fields you BIND need defaults
  { "new-field" := nf }
  ... )
```

## Query Costs — local-only
- `select`, `keys`, and full-table scans are **expensive and intended for `/local` (read-only) queries** — do not use them in on-chain transaction paths; they scan the whole table and will blow the gas budget.
- **`fold-db` is a map, NOT a reduce** — it applies a function across matching rows and returns a list; it does not accumulate into a single value (see canonical traps). It is also a local-only scan operation.

## Anti-Patterns
- ❌ Row keys are NOT schema fields — a key cannot be read back from a row result; store it in a column if you need it.
- ❌ Missing bound fields in `with-default-read` defaults → runtime error.
- ❌ Zero/empty defaults that bypass validation checks.
- ❌ Storing computed values that can be derived on read.
- ❌ Assuming a field exists without verifying the `.pact` source.
- ❌ Using `select`/`keys` in a transaction (local-only).
