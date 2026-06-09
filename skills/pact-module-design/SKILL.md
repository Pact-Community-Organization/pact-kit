---
name: pact-module-design
description: "Pact 5 module architecture — governance, table ownership, namespace, deploy patterns, and module structure for KDA-CE smart contracts."
---
# Pact Module Design

## Module Template
```pact
(namespace "free")

(module my-module GOVERNANCE
  @doc "Module purpose and responsibility"

  ;; ============================================================
  ;; SCHEMAS
  ;; ============================================================
  (defschema my-schema
    @doc "Schema description"
    field1:type1
    field2:type2)

  (deftable my-table:{my-schema})

  ;; ============================================================
  ;; CAPABILITIES
  ;; ============================================================
  (defcap GOVERNANCE ()
    (enforce-guard (keyset-ref-guard "free.my-admin-keyset")))

  ;; ============================================================
  ;; CORE FUNCTIONS
  ;; ============================================================

  ;; ============================================================
  ;; ADMIN FUNCTIONS
  ;; ============================================================
)

;; Table creation (same tx as module deploy)
(create-table my-table)
```

## Governance Pattern
- `keyset-ref-guard` for external keyset governance
- Governance cap required for admin functions
- Module upgrade = redeploy with same governance keyset

## Module Size Guidelines
- Small module (< 10 functions): single deploy tx
- Large module (> 30 functions): may need split deploy
- Always measure gas via local preflight
