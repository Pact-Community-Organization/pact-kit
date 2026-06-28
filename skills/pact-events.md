---
name: pact-events
description: "Pact 5 events: @event capabilities, managed-cap emission, emit-event behavior, event shape, and env-events REPL tests for indexing."
---
# Pact Events

> Canonical traps: [../instructions/pact-traps.md](../instructions/pact-traps.md)

## Emission Rules (source-anchored)
- `@event` on a **basic capability** emits an event on successful **normal acquisition** (`with-capability`). `test-capability` does **not** emit — emission is guarded by `NormalCapEval` (source: `evalCap` `DefEvent` branch, `emittedEvent = fqctToPactEvent origToken <$ guard (ecType == NormalCapEval)` in `pact/Pact/Core/IR/Eval/CEK/Evaluator.hs`).
- **`@managed` capabilities also emit on normal acquisition** without needing `@event`. The event carries the **original (unfiltered) token args** — including the managed parameter — not the post-filter token (source: same `evalCap`, user-managed and auto-managed branches use `fqctToPactEvent origToken`).
- A **plain (unmanaged, non-`@event`) capability does NOT emit** on acquisition.
- `emit-event` records an event from a capability application **without evaluating the capability body**, and **returns `true`** (source: `coreEmitEvent` returns `VBool True` in `pact/Pact/Core/IR/Eval/CEK/CoreBuiltin.hs` and its Direct variant).
- `emit-event` **requires the cap to be `@event` or `@managed`** — calling it on a plain cap throws `InvalidEventCap`. It is also **module-scoped**: emitting a cap whose module ≠ the calling module throws `EventDoesNotMatchModule` (verified by static tests `install_cap_not_managed` / `emit_event_module_mismatch`). See canonical traps for exact REPL-vs-on-chain strings.
- Practical rule: capability-acquisition emission and explicit `emit-event` are separate paths; avoid combining both for the same semantic transition unless duplicate events are intentional.
- Execution flags: `FlagDisablePactEvents` suppresses **all** event emission; `FlagEnableLegacyEventHashes` switches the recorded `module-hash` to the module's current hash (`emitLegacyCapability`).

```pact
;; Managed cap — auto-emits on acquisition with (sender receiver amount)
(defcap TRANSFER (sender:string receiver:string amount:decimal)
  @managed amount TRANSFER-mgr
  (enforce-guard (at 'guard (read accounts sender))))

;; Basic @event cap — emits on every acquisition
(defcap CREDIT (receiver:string)
  @event
  true)

;; emit-event — fires the event without running any cap body
(defcap TRANSFER_XCHAIN_RECD (sender:string receiver:string amount:decimal source-chain:string)
  @event true)

(defun mark-received (s:string r:string a:decimal src:string)
  (emit-event (TRANSFER_XCHAIN_RECD s r a src)))
```

## Event Shape
Rendered event record (off-chain / `env-events`):
```
{ name: "free.my-module.CAP"   ;; fully-qualified module.CAP
, params: [ ... ]              ;; the capability arguments
, module-hash: "..." }
```
Internally a `PactEvent` is `{ _peName, _peArgs, _peModule, _peModuleHash }` (`pact/Pact/Core/Capabilities.hs`); the rendered `name` qualifies `_peName` with its module.

### Synthetic cross-chain events
Cross-chain defpacts emit reserved events under the **`pact` module** (not the user module) via `emitReservedEvent`:
- `X_YIELD` — emitted on a step that yields cross-chain; params `[ target-chain-id, "<qualified-continuation-name>", [continuation-args] ]`.
- `X_RESUME` — emitted on cross-chain resume; params `[ source-chain-id, "<qualified-continuation-name>", [continuation-args] ]`.

Source: `emitXChainEvents` / `emitReservedEvent` in `pact-repl/Pact/Core/IR/Eval/Direct/Evaluator.hs` and `pact/Pact/Core/IR/Eval/Runtime/Utils.hs`.

## Use Cases
- Off-chain indexing and event-sourcing.
- Audit trail / non-repudiation.
- A "missing events" security finding maps directly here — privileged state changes should emit an event for observability.

## REPL Testing
`(env-events true)` returns and clears the accumulated event list.

```pact
(begin-tx "transfer emits managed + credit events")
(env-events true)                       ;; clear
(free.my-module.transfer "alice" "bob" 5.0)
(expect "two events emitted"
  [ { "name": "free.my-module.TRANSFER"
    , "params": ["alice" "bob" 5.0]
    , "module-hash": (at 'hash (describe-module "free.my-module")) }
    { "name": "free.my-module.CREDIT"
    , "params": ["bob"]
    , "module-hash": (at 'hash (describe-module "free.my-module")) } ]
  (env-events true))
(commit-tx)
```
