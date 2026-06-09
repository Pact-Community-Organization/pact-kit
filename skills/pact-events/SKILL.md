---
name: pact-events
description: "Pact 5 events — @event capabilities, automatic managed-cap emission, emit-event without body evaluation, event shape, and env-events REPL testing for off-chain indexing on KDA-CE."
---
# Pact Events

> Canonical traps: [.github/instructions/pact-traps.instructions.md](../../instructions/pact-traps.instructions.md)

## Emission Rules
- `@event` on a **basic capability** emits an event on **every successful acquisition**.
- **Managed capabilities emit AUTOMATICALLY** — no `@event` annotation needed. A managed cap emits **once** on install / first-acquire, carrying the install arguments.
- **VERIFIED:** managed and `@event` caps auto-emit — **do NOT** also call `emit-event` for the same acquisition, or you double-emit.
- `emit-event` emits an event **WITHOUT evaluating the capability body**. coin uses this for `TRANSFER` and `TRANSFER_XCHAIN_RECD` (the latter has no acquirable body — it exists purely as an event).

```pact
;; Managed cap — auto-emits on install with (sender receiver amount)
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
```
{ name: "free.my-module.CAP"
, params: [ ... ]            ;; the capability arguments
, module-hash: "..." }
```

Synthetic cross-chain events `X_YIELD` / `X_RESUME` are emitted automatically by cross-chain defpacts for off-chain tracking.

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
