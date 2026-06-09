---
name: code-generation
description: "Pact module scaffolding — generate module, interface, schema, capability, and function boilerplate for new Pact 5 smart contracts."
---
# Code Generation

## New Module Scaffold
Generate the following files for a new Pact module:
1. `pact/interfaces/{name}-iface.pact` — Interface (if needed)
2. `pact/modules/{name}.pact` — Module implementation
3. `pact/tests/{name}.repl` — REPL tests
4. `pact/deploy/{name}-deploy.ts` — Deploy script

## Module Template Variables
- `{module-name}` — kebab-case module name
- `{governance-keyset}` — governance keyset name
- `{namespace}` — target namespace

## Generated Module Structure
```pact
(namespace "{namespace}")
(module {module-name} GOVERNANCE
  @doc "{module-name} — {description}"
  (defcap GOVERNANCE ()
    (enforce-guard (keyset-ref-guard "{governance-keyset}")))
  ;; Schemas
  ;; Tables
  ;; Capabilities
  ;; Functions
)
(create-table ...)
```

## Generated Test Structure
```pact
(begin-tx "Setup")
;; Environment setup
(commit-tx)
(begin-tx "Test: happy path")
;; Test implementation
(commit-tx)
```
