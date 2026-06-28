---
name: pact-module-design
description: "Pact 5 module architecture — governance, table ownership, namespace, deploy patterns, and module structure for KDA-CE smart contracts."
---
# Pact Module Design

> Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md)

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
Governance is declared in the module header and must be **either** a bare keyset
name (`KeyGov`) **or** a 0-argument `defcap` (`CapGov`); anything else fails at
load with `InvalidGovernanceRef` ("Invalid governance. Must be a 0-argument
defcap or a keyset").
- **Keyset governance:** `(module m 'admin-keyset ...)` — the named keyset is
  enforced on install and on every upgrade.
- **Capability governance:** `(module m GOVERNANCE ...)` with `(defcap GOVERNANCE () ...)`.
  The defcap body is **granted without being tested on the initial install** and
  is enforced only on subsequent upgrades — so its body must contain real
  authorization (`enforce-guard` / on-chain check), never `true`.
- `keyset-ref-guard` is the usual cap-governance body for external keyset control.
- Governance cap is also required to guard admin functions.
- Module upgrade = redeploy under the same module name; governance must pass.
- Old code hashes can be `bless`ed so prior module-hash references remain callable.

## Module Admin & Cross-Module Access (source-anchored)
- **Module admin = the right to touch a module's tables / call its guarded ops
  from outside.** Held for the rest of the transaction once acquired
  (`esCaps.csModuleAdmin`).
- It is granted automatically while executing **inside** the owning module
  (`guardForModuleCall`: caller-module == target-module). From **outside**, you
  must explicitly acquire it or the op fails `ModuleAdminNotAcquired`
  ("Module admin is necessary for operation but has not been acquired:").
- **`(acquire-module-admin some-module)`** (modref arg) runs the module's
  governance — `KeyGov` enforces the keyset-name is in sigs; `CapGov` evaluates
  the 0-arg governance defcap — and on success grants admin for the rest of the tx,
  returning `"Module admin for module <m> acquired"`. It fails (e.g.
  `KeysetPredicateFailure` / a failing gov cap) if you don't actually own governance.
- A **non-upgradeable module** (`(defcap GOV () (enforce false ...))`) can never
  have its governance pass, so its tables are immutable from outside — only the
  module's own code can write them. (REPL test escape hatch: `(env-module-admin m)`
  force-grants admin, bypassing checks — REPL only.)

## Upgrade, bless & redeploy
- **Upgrade** = redeploy under the same module name. On upgrade the **existing**
  module's governance is enforced (`evalModuleGovernance`); on the **very first**
  install, `KeyGov` enforces the module keyset but `CapGov` is **granted without
  testing** the cap body.
- **`(bless "<module-hash>")`** in the module body records an old code hash in the
  module's blessed set (`_mBlessed`). A cross-module call that resolves to a module
  at hash `h` succeeds only if `h` == the current hash **or** `h ∈ blessed`
  (`enforceBlessedHashes`); otherwise `HashNotBlessed`. **Bless prior versions** so
  in-flight references (stored guards, mid-flight defpacts, pre-upgrade callers)
  keep working after an upgrade. A malformed hash literal fails load with
  `InvalidBlessedHash`.
- **`(static-redeploy "m")`** (top-level only) redeploys a module **with no code
  change**, re-storing it in the Pact 5 compact format so it loads with much less
  gas; **governance is unchanged**. Use it to migrate legacy modules cheaply.
- **`(describe-module "m")`** is **top-level + local-only** (`checkNonLocalAllowed`);
  returns `{ name, hash, code, blessed, interfaces, ... }`. `(list-modules)` is also
  local-only. Neither is callable on a transactional on-chain path.

## Standard utility library — `pact-util-lib` (Pascal / `free` namespace)
`free.util-lists`, `free.util-strings`, `free.util-math`, `free.util-time`, `free.util-random`,
`free.util-zk`, `free.util-chain-data`, `free.util-fungible` (v0.11; verify 5.4ce compatibility) are MIT-licensed,
maintained by Pascal (a core KDA-CE developer), and **deployed on mainnet** in the `free` namespace.
They are pure-Pact compositions of native builtins — e.g. `util-lists` wraps
`take`/`drop`/`enumerate`/`zip`/`fold`; `util-strings` builds `split`/`join`/`slice`/`upper`/`lower`/
`str-to-decimal` on `str-to-list`/`concat`/`format`. Docs: pact-util-lib.readthedocs.io.

**Reuse-vs-reimplement decision (default: reimplement the one helper you need):**
- The author flags the lib as **Beta and UNAUDITED** — its own headers warn: *"BE CAREFUL if a
  security enforcement depends on one of these functions."* Never put a security invariant
  behind a `free.util-*` call.
- Taking a cross-module **dependency** on `free.util-*` couples us to a module governed by an external
  keyset (`free.util-lib`) that its owner can upgrade — a supply-chain / blast-radius risk (see
  cross-module rules) plus the cost of a cross-module call and an external trust edge.
- **Default (minimal-first / YAGNI):** the MIT license lets us **copy the exact function inline** into
  our module. Prefer this for the 1–3 helpers a contract actually needs, and unit-test them against the
  native traps (take/drop clamping, inclusive `enumerate`, `at`-not-on-strings, `zip`-shortest) — see
  [../instructions/pact-traps.md](../instructions/pact-traps.md).
- **Reuse the deployed module as a dependency** only for non-security, read-only convenience on a
  throwaway/local path, with the version pinned and reviewed.
- Treat the lib as a **vetted reference implementation** of native composition, never as a trusted
  security primitive.

## Module Size Guidelines
- Small module (< 10 functions): single deploy tx
- Large module (> 30 functions): may need split deploy
- Always measure gas via local preflight
