---
name: pact-interface-design
description: "Pact 5 interface definition and implementation — fungible-v2, cross-module contracts, interface compliance verification for KDA-CE."
---
# Pact Interface Design

> Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md)

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
- `my-types` — example shared interface for your modules

## Rules
- **Interfaces are immutable** — re-deploying an interface fails with
  `CannotUpgradeInterface` ("Interface cannot be upgraded:"). Add new
  requirements as a **new interface version** instead.
- Interfaces may contain only **signatures** (`defun`, `defcap`, `defpact` with
  no body), plus `defconst`, `defschema`, `use`, and `@model`/`@doc` metadata —
  **no function bodies, no `deftable`, no governance**.
- A `defcap` signature in an interface carries its managed/event metadata
  (`@managed` / `@event`); implementers must match it.
- `(implements iface)` requires every interface member to be implemented with an
  **exact** signature (name, arity, types); a missing or mismatched member fails
  desugaring with `NotImplemented` / `ImplementationError`.
- All public functions should carry a `@doc` annotation.
