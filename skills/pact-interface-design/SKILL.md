---
name: pact-interface-design
description: "Pact 5 interface definition and implementation — fungible-v2, cross-module contracts, interface compliance verification for KDA-CE."
---
# Pact Interface Design

## Interface Definition
```pact
(interface my-interface
  @doc "Interface purpose"

  (defun required-function:return-type (param:type)
    @doc "What implementations must provide")

  (defcap REQUIRED-CAP (param:type)
    @doc "Required capability")

  (defconst CONSTANT_VALUE:type value
    @doc "Shared constant"))
```

## Implementation
```pact
(module my-module GOVERNANCE
  (implements my-interface)

  (defun required-function:return-type (param:type)
    ; Must match interface signature exactly
    ...)

  (defcap REQUIRED-CAP (param:type)
    ; Must match interface signature exactly
    ...))
```

## Key Interfaces
- `fungible-v2` — Token standard (transfer, balance, etc.)
- `fungible-xchain-v1` — Cross-chain transfer support
- `governance-types` — Project-specific shared types for DAO modules

## Rules
- Interfaces cannot be upgraded once deployed
- Adding new requirements = new interface version
- All public functions must have `@doc` annotation
- Implementation must match exact signature (types, arity)
