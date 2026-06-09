---
description: "Use when writing Pact 5 smart contracts (.pact files), REPL tests (.repl files), or reviewing Pact code for KDA-CE. Critical language traps, patterns, and mandatory conventions."
applyTo: ["**/*.pact", "**/*.repl"]
---
# Pact 5 Language Rules

## Critical Traps

**Canonical trap list lives in [pact-traps.instructions.md](pact-traps.instructions.md) — see there.**

Most-violated corrections (read the canonical file for the full list + error strings):

- **`enforce` / `try`**: no DML inside the boolean arg / block — **reads ARE allowed**. Binding reads to a `let` is style/gas, not correctness.
- **`with-default-read`**: the default object must contain every field you **BIND**, not every schema field.
- **Native name shadowing** (`exp`, `abs`, `log`, `mod`, `round`, `ln`, `sqrt`, `floor`, `ceiling`, …): **load-time rejected** in Pact 5.1+ — `Variable X shadows native of the same name`.
- **`pact-id`**: `(pact-id)` **throws outside a defpact** and proves nothing about identity inside one — gate with composed capabilities bound to identity.

## Capability Security Pattern
```pact
(defcap GOVERNANCE ()
  (enforce-guard (keyset-ref-guard "my-keyset")))

(defcap ADMIN ()
  (compose-capability (GOVERNANCE)))

(defun admin-only-function ()
  (with-capability (ADMIN)
    ; privileged code here
  ))
```

## Testing Conventions (.repl)
- Use `env-data` and `env-sigs` before each transaction
- Reset state between tests: don't rely on prior test state
- Use specific error strings in `expect-failure`, never `""`
- Test both positive (authorized) and negative (unauthorized) paths
- Comment each test block with the requirement it validates

## Module Structure
```pact
(namespace "free")
(module my-module GOVERNANCE
  @doc "Module description"

  ; 1. Schema definitions
  ; 2. Table declarations
  ; 3. Capabilities
  ; 4. Core functions
  ; 5. Admin functions
  ; 6. Utility functions
)
(create-table my-table)
```

## Naming Conventions
- Modules: `kebab-case` (e.g., `governance-token`)
- Functions: `kebab-case` (e.g., `get-balance`)
- Capabilities: `UPPER-CASE` (e.g., `TRANSFER`, `GOVERNANCE`)
- Tables: `kebab-case-table` (e.g., `account-table`)
- Schema: `kebab-case-schema` (e.g., `account-schema`)
