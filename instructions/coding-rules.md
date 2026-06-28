---
description: "Use when writing Pact 5 smart contract code, TypeScript integration code, or other KDA-CE implementation. Covers style, naming, agent tags, and patterns."
applyTo: ["**/*.pact", "**/*.ts", "**/*.js"]
---
# Coding Rules

## Pact 5 (.pact files)
- Target **Pact 5** exclusively — no Pact 4 legacy patterns
- Use `let` (not `let*`) — equivalent in Pact 5; `let` is convention
- Capability-driven access control for all privileged operations
- `@doc` on every public `defun`, `defcap`, `defpact`
- Comments prefixed with agent tag: `; [Developer] explanation`
- Namespace: `free.` for development, project namespace for production
- Module governance: keyset-ref-guard pattern
- **Language traps**: see canonical [pact-traps.md](pact-traps.md) — do not re-list traps here. `test-capability` runs the defcap body; `expect` records failures and continues; `expect-failure` does NOT roll back prior REPL DB writes (all documented canonically there).

## TypeScript/JavaScript
- Strict TypeScript for all integration code
- Decimal values in SDK cap args: `{ decimal: 'N.0' }` — never raw JS numbers
- Gas limit constants: `150_000` (hard ceiling)

## Agent Tags
- All generated content tagged: `[Admin]`, `[Architect]`, `[Developer]`, `[Tester]`, `[Security]`, `[DevOps]`, `[Product]`, `[Docs]`, `[Support]`
- All agents share the same GitHub user — tags are the identity mechanism

## Cross-Module Completeness
When adding/modifying a module:
1. Check deploy-order neighbors (N-1, N+1)
2. Walk full lifecycle across ALL modules
3. New per-account state → update ALL balance-changing functions
4. Config fields → verify tracking schema has matching field

## On-Chain Transparency Guardrail
- Keep authoritative business state on-chain by default.
- Record final business outcomes in state and emit matching events for audit reconstruction.
- Restrict off-chain computation to orchestration, indexing, or non-feasible heavy compute.
- Document every off-chain boundary with inputs, outputs, and the on-chain finalization step.
