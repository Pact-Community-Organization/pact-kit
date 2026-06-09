---
name: api-design
description: "Pact function signature design, interface definition, capability API patterns, and public function contracts for KDA-CE smart contracts."
---
# API Design

## Function Signature Template
```pact
(defun function-name:return-type
  ( param1:type1
    param2:type2
  )
  @doc "Description of what this function does"
  ; Implementation
)
```

## Design Principles
1. **Minimal surface area** — Only expose what consumers need
2. **Explicit parameters** — No hidden state dependencies
3. **Typed returns** — Always specify return type
4. **Guard early** — Capability checks at function entry
5. **Idempotent reads** — Read functions have no side effects

## Interface Design
```pact
(interface my-interface
  @doc "Interface description"
  (defun required-function:return-type (param:type)
    @doc "What implementations must provide")
  (defcap REQUIRED-CAP ()
    @doc "Required capability"))
```

## Versioning
- Interfaces are immutable once deployed — add new interface for breaking changes
- Module upgrades preserve table data — no destructive migrations
