---
name: pact-architecture
description: "Kadena-specific architecture patterns for Pact 5 on KDA-CE. Governance models, namespace management, upgrade patterns, and capability composition."
---
# Pact Architecture Patterns

> Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md)

## Governance Models
```pact
; Keyset governance (most common)
(module my-module GOVERNANCE
  (defcap GOVERNANCE ()
    (enforce-guard (keyset-ref-guard "my-admin-keyset"))))

; Capability governance (autonomous / upgradeable by on-chain logic)
; On INITIAL install the GOVERNANCE body is NOT evaluated; it is enforced
; only on UPGRADE. Gate it on real on-chain state — never a no-op body.
(module my-module GOVERNANCE
  (defcap GOVERNANCE ()
    (enforce-guard (at 'guard (read protocol-state ADMIN_KEY)))))
```

Governance must be either a bare keyset name (`KeyGov`) or a **0-argument
defcap** (`CapGov`); anything else fails at load with `InvalidGovernanceRef`
("Invalid governance. Must be a 0-argument defcap or a keyset"). With
capability governance, the defcap body is **granted without being tested on the
initial install** and is enforced only on subsequent upgrades — so the body must
contain real authorization, never `true`.

## Namespace Management
- Development: `free.` namespace (a pre-defined open namespace on KDA-CE).
- Production: a **principal namespace** — an `n_<hash>` identifier guarded by an admin keyset. NOTE: the `n_` derivation is a **chainweb `ns`-contract / tooling convention**, NOT a Pact-core native behavior; `define-namespace` itself accepts any valid name.
- Example: `n_560eefcee4a090a24f12d7cf68cd48f11d8d2bd9`

### Source-anchored namespace mechanics (Pact 5)
Two distinct natives, both **top-level only** (`enforceTopLevelOnly`):
- **`(namespace "name")`** — sets the *active* namespace for subsequent definitions;
  reads it from the DB (missing → `NamespaceNotFound`). `(namespace "")` resets to
  **root**. Returns `"Namespace set to <name>"`.
- **`(define-namespace name user-guard admin-guard)`** — creates or updates a
  namespace record `{ name, user-guard, admin-guard }`. Returns
  `"Namespace defined: <name>"`.
  - **Name format** (`isValidNsFormat`): first char must be a latin1 **letter**;
    remaining chars latin1 alphanumeric or one of `%#+-_&$@<>=^?*!|/~`. Bad format →
    `NativeExecutionError "invalid namespace format"`.

**Which guard governs WHAT (security-critical, easy to get wrong):**
- **Updating an existing namespace** enforces that namespace's **admin guard**
  (the third arg / `_nsAdmin`) before overwriting — only the admin can rotate it.
- **Installing a module/interface inside an active namespace** enforces that
  namespace's **user guard** (`_nsUser`) — via the magic `NAMESPACE` owner cap
  (`enforceNamespaceInstall`). So the user guard controls *who may deploy into the
  namespace*; the admin guard controls *who may change the namespace itself*.

**Namespace policy** (`NamespacePolicy`):
- `SimpleNamespacePolicy` (default) — anyone may create namespaces and deploy in root.
- `SmartNamespacePolicy allowRoot ns-policy-fn` — a host-installed `(ns admin-guard)->bool`
  defun gates **new** namespace creation (returning `false` → "Namespace definition
  not permitted"); `allowRoot` gates root-namespace module installs. Deploying a
  module in root when disallowed → `RootNamespaceInstallError`. (REPL: install via
  `(env-namespace-policy allowRoot (policy-fn))`; on-chain the host/chainweb sets it.)
- `define-keyset` inside a namespace must use the matching `ns.keyset` name and is
  gated by the namespace owner cap (see canonical traps / pact-guards).

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
