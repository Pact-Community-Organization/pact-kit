---
name: compliance-verification
description: "Standard compliance verification for Pact 5 — fungible-v2 + fungible-xchain-v1 compliance, interface implementation checks, and platform requirement validation for KDA-CE."
---
# Compliance Verification

> Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md).
> Source of truth: `pact/coin-contract/v2/fungible-v2.pact` and `pact/coin-contract/v4/fungible-xchain-v1.pact` in kda-community/chainweb-node.

## fungible-v2 — the FULL required surface

A token claiming `(implements fungible-v2)` MUST provide **every** member below
with an **exact** signature match. A partial implementation is non-compliant even
if it loads.

### Functions
- [ ] `transfer:string (sender:string receiver:string amount:decimal)`
- [ ] `transfer-create:string (sender:string receiver:string receiver-guard:guard amount:decimal)`
- [ ] `transfer-crosschain:string (sender:string receiver:string receiver-guard:guard target-chain:string amount:decimal)` — **a `defpact`** (not a plain defun; 2-step SPV)
- [ ] `get-balance:decimal (account:string)`
- [ ] `details:object{fungible-v2.account-details} (account:string)`
- [ ] `precision:integer ()` — return `12` for KDA-compatible tokens (matches coin constant `MINIMUM_PRECISION`)
- [ ] `enforce-unit:bool (amount:decimal)`
- [ ] `create-account:string (account:string guard:guard)`
- [ ] `rotate:string (account:string new-guard:guard)`

### Capability (managed)
- [ ] `TRANSFER:bool (sender:string receiver:string amount:decimal)` — `@managed amount TRANSFER-mgr`
- [ ] `TRANSFER-mgr:decimal (managed:decimal requested:decimal)` — **decremental**: subtracts, enforces `>= 0`, returns remainder

## fungible-xchain-v1 — the FULL required surface

**This is a SEPARATE interface from fungible-v2** (source: `pact/coin-contract/v4/fungible-xchain-v1.pact`).
SPT implements BOTH `fungible-v2` AND `fungible-xchain-v1`. coin-v5 is the reference implementation of both.

- [ ] `TRANSFER_XCHAIN:bool (sender:string receiver:string amount:decimal target-chain:string)` — `@managed amount TRANSFER_XCHAIN-mgr`
- [ ] `TRANSFER_XCHAIN-mgr:decimal (managed:decimal requested:decimal)` — **ONE-SHOT: always returns `0.0`** (not the remainder)
- [ ] `TRANSFER_XCHAIN_RECD:bool (sender:string receiver:string amount:decimal source-chain:string)` — `@event` only — emitted on the receiving chain in step 2 of `transfer-crosschain`

> **TRANSFER_XCHAIN-mgr is one-shot.** Unlike TRANSFER-mgr which returns `(- managed requested)`,
> TRANSFER_XCHAIN-mgr returns `0.0` — the cap is exhausted after a single cross-chain transfer.
> This is by design: one `install-capability (TRANSFER_XCHAIN ...)` permits exactly one cross-chain send.

## Managed-capability obligations

Manager function behavior differs by interface — do not conflate them:

**TRANSFER-mgr (fungible-v2) — decremental:**
- [ ] Subtracts `requested` from `managed`
- [ ] Enforces result `>= 0.0`
- [ ] Returns the **decremented remainder** (new managed balance threads forward for partial allowances)

**TRANSFER_XCHAIN-mgr (fungible-xchain-v1) — one-shot:**
- [ ] Enforces `requested <= managed` (one transfer cannot exceed the installed amount)
- [ ] Returns **`0.0`** — cap is exhausted after use; cannot be partially reused

(See `pact-capabilities` for all manager-function bug variants.)

## Precision / rounding obligations
- [ ] A `MINIMUM_PRECISION` constant exists (`12` for KDA-compatible tokens) and `precision` returns it.
- [ ] `enforce-unit` rejects any amount whose precision exceeds `MINIMUM_PRECISION`.
- [ ] **`enforce-unit` is called on EVERY externally supplied amount** — in
      `transfer`, `transfer-create`, and each step of `transfer-crosschain`.
- [ ] Rounding follows Pact banker's rounding (round-half-to-even) — never roll
      a custom rounder that drifts.

## Interface immutability
- [ ] **Interfaces cannot be upgraded and are not governed.** Once deployed, `fungible-v2`
      and `fungible-xchain-v1` are fixed — only the implementing module is upgradeable
      (under its own governance).

## Interface compliance check (run this)
1. List every interface the module `implements`.
2. For each interface **function**: signature (name, arg types, return type) is an
   exact match — including `defpact` vs `defun` for `transfer-crosschain`.
3. For each interface **capability**: signature and `@managed`/`@event`/manager match.
4. TRANSFER-mgr: subtract → enforce `>= 0` → return remainder.
5. TRANSFER_XCHAIN-mgr: enforce `requested <= managed` → return `0.0` (one-shot).
6. TRANSFER_XCHAIN_RECD: `@event` only — no body logic.
7. `enforce-unit` invoked on every external amount; `precision`/`MINIMUM_PRECISION` consistent.
8. All interface **constants** are accessible.
9. `(typecheck 'module)` passes (catches signature drift authoritatively).

## KDA-CE platform compliance
- [ ] Gas under 150k for all operations.
- [ ] Valid chain IDs (0–19).
- [ ] Correct network ID for the target environment.
- [ ] Pact 5 syntax only (no deprecated Pact 4 patterns; no deprecated module/pact guards).
