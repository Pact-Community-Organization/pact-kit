---
name: pact-architecture
description: "Kadena-specific architecture patterns for Pact 5 on KDA-CE. Governance models, namespace management, upgrade patterns, and capability composition."
---
# Pact Architecture Patterns

## Governance Models
```pact
; Keyset governance (most common)
(module my-module GOVERNANCE
  (defcap GOVERNANCE ()
    (enforce-guard (keyset-ref-guard "my-admin-keyset"))))

; Capability governance (autonomous)
(module my-module GOVERNANCE
  (defcap GOVERNANCE ()
    (enforce-pact-exec)))
```

## Namespace Management
- Development: `free.` namespace
- Production: principal namespace from admin keyset
- Example: `n_560eefcee4a090a24f12d7cf68cd48f11d8d2bd9`

## Module Upgrade Pattern
1. Deploy new module code with same module name
2. Governance keyset must sign
3. Table data preserved automatically
4. New schema fields need `with-default-read` in existing reads

## Capability Composition
```pact
(defcap ADMIN ()
  (compose-capability (GOVERNANCE)))

(defcap TRANSFER (sender receiver amount)
  @managed amount TRANSFER-mgr
  (compose-capability (DEBIT sender))
  (compose-capability (CREDIT receiver)))
```
