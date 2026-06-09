---
description: "Developer: Scaffold a new Pact 5 module with governance, schemas, capabilities, functions, REPL tests, and deploy script."
---
# New Pact Module

## Input
- Module name (kebab-case)
- Purpose/responsibility
- Schema fields and types
- Required capabilities
- Public functions

## Generated Files
1. `pact/modules/{name}.pact` — Module implementation
2. `pact/tests/{name}.repl` — REPL test suite
3. `pact/deploy/{name}-deploy.ts` — Deploy script (if applicable)

## Module Template
```pact
(namespace "free")
(module {name} GOVERNANCE
  @doc "{description}"

  (defcap GOVERNANCE ()
    (enforce-guard (keyset-ref-guard "free.{admin-keyset}")))

  ;; Schemas
  ;; Tables
  ;; Capabilities  
  ;; Core functions
  ;; Admin functions
)
(create-table ...)
```

## Test Template
```pact
(begin-tx "Setup")
;; env-data, env-sigs, namespace, keyset, load module
(commit-tx)

;; One tx per test case
;; Both positive and negative tests
;; Cite requirement source in comments
```
