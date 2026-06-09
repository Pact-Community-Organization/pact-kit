---
description: "Developer: Evolve a Pact 5 table schema — Pact has NO in-place migration. Declare a new table (usually a new module version), write admin-guarded read-old/write-new migration fns, freeze the old table, bless old module hashes, and prove row-count conservation with a REPL + devnet harness."
---
# Migrate a Pact Schema

> Canonical traps: [../instructions/pact-traps.instructions.md](../instructions/pact-traps.instructions.md)
> Skill: [pact-schema-design](../skills/pact-schema-design/SKILL.md)

## Core fact
**Pact has NO in-place schema migration.** You cannot add/retype a column on an
existing table. Schema evolution = declare a **NEW table** and copy data forward.

## 1. Declare the new table
- Define the new schema and a new `deftable` — typically in a **new module version**.
- Respect `deftable` / `create-table` ordering (table created after the module loads).
- Choose the table name so old and new coexist (e.g. `accounts-v2`).

## 2. Admin-guarded migration functions
- Write `read-old` / `write-new` migration functions that read each row from the
  old table and write the transformed row into the new table.
- Guard **every** migration write behind the module-admin capability
  (`with-capability (GOVERNANCE)` / module admin) — never an unguarded write.
- Migrate in **bounded batches** (key lists), not one unbounded `select`/`keys`
  scan on-chain — those are local-only / gas-and-determinism risks (canonical traps).

## 3. Freeze the old table
- After migration, treat the old table as **read-only/frozen**. Do **NOT** delete
  rows — Pact has no row delete; use an `active:bool` tombstone where a logical
  delete is required, and stop writing to the old table from new code.

## 4. Bless old module hashes
- Any in-flight reference (e.g. a pending defpact, or a cross-module call pinned
  to the prior code) needs the old module hash **blessed** so it keeps resolving:
  add `(bless "<old-module-hash>")` in the new module version.
- Record which hashes are blessed and why (which in-flight references depend on them).

## 5. Migration test harness — prove no data loss
- **REPL**: load old module + seed rows → load new version → run migration →
  assert new-table row count == old-table row count, and spot-check transformed
  fields row-by-row. Assert no source row was dropped or double-written.
- **Devnet**: deploy old → seed → deploy new version → run batched migration →
  re-query and confirm row-count conservation and field integrity on-chain.
- Assert the old table is frozen (a post-migration write to it is rejected/blocked).

## Output
- New schema + `deftable` block.
- Admin-guarded `read-old`/`write-new` functions (batched).
- `bless` list with justification.
- REPL + devnet migration test plan with the row-count-conservation assertion.
