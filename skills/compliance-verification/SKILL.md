---
name: compliance-verification
description: "Standard compliance verification for Pact 5 — fungible-v2 compliance, interface implementation checks, and platform requirement validation for KDA-CE."
---
# Compliance Verification

> Canonical traps: [../../instructions/pact-traps.instructions.md](../../instructions/pact-traps.instructions.md).

## fungible-v2 — the FULL required surface

A token claiming `(implements fungible-v2)` MUST provide **every** member below
with an **exact** signature match. A partial implementation is non-compliant even
if it loads.

### Functions
- [ ] `transfer:string (sender:string receiver:string amount:decimal)`
- [ ] `transfer-create:string (sender:string receiver:string receiver-guard:guard amount:decimal)`
- [ ] `transfer-crosschain:string (sender:string receiver:string receiver-guard:guard target-chain:string amount:decimal)` — **a `defpact`** (not a plain defun)
- [ ] `get-balance:decimal (account:string)`
- [ ] `details:object{fungible-v2.account-details} (account:string)`
- [ ] `precision:integer ()`
- [ ] `enforce-unit:bool (amount:decimal)`
- [ ] `create-account:string (account:string guard:guard)`
- [ ] `rotate:string (account:string new-guard:guard)`

### Capabilities (managed)
- [ ] `TRANSFER:bool (sender:string receiver:string amount:decimal)` — `@managed amount TRANSFER-mgr`
- [ ] `TRANSFER_XCHAIN:bool (sender:string receiver:string amount:decimal target-chain:string)` — `@managed amount TRANSFER_XCHAIN-mgr`

> Common gap: the previous checklist omitted `transfer-crosschain`,
> `TRANSFER_XCHAIN`, `enforce-unit`, and treated `transfer-crosschain` as a defun.
> All four are mandatory; `transfer-crosschain` MUST be a `defpact`.

## Managed-capability obligations

For each managed cap, verify the manager function honors the contract:
- [ ] `TRANSFER-mgr` / `TRANSFER_XCHAIN-mgr` **subtracts** `requested` from `managed`.
- [ ] **Enforces** the result `>= 0.0`.
- [ ] **Returns** the decremented remainder (not `managed` unchanged, not `requested`).

(See `pact-capabilities` for the manager-function bug variants.)

## Precision / rounding obligations
- [ ] A `MINIMUM_PRECISION` constant exists and `precision` returns it.
- [ ] `enforce-unit` rejects any amount whose precision exceeds `MINIMUM_PRECISION`.
- [ ] **`enforce-unit` is called on EVERY externally supplied amount** — in
      `transfer`, `transfer-create`, and each step of `transfer-crosschain`.
- [ ] Rounding follows Pact banker's rounding (round-half-to-even) — never roll
      a custom rounder that drifts.

## Interface immutability
- [ ] **Interfaces cannot be upgraded and are not governed.** Once `fungible-v2`
      is deployed it is fixed; do not assume you can patch the interface — only
      the implementing module is upgradeable (under its own governance).

## Interface compliance check (run this)
1. List every interface the module `implements`.
2. For each interface **function**: signature (name, arg types, return type) is an
   exact match — including `defpact` vs `defun` for `transfer-crosschain`.
3. For each interface **capability**: signature and `@managed`/manager match.
4. Each managed manager fn: subtract → enforce `>= 0` → return remainder.
5. `enforce-unit` invoked on every external amount; `precision`/`MINIMUM_PRECISION`
   consistent.
6. All interface **constants** are accessible.
7. `(typecheck 'module)` passes (catches signature drift authoritatively).

## KDA-CE platform compliance
- [ ] Gas under 150k for all operations.
- [ ] Valid chain IDs (0–19).
- [ ] Correct network ID for the target environment.
- [ ] Pact 5 syntax only (no deprecated Pact 4 patterns; no deprecated module/pact
      guards).
