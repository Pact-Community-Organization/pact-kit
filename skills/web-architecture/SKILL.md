---
name: web-architecture
description: "Web architecture patterns for Pact Community — three-origin split, layered modules (wallet/chain/features/ui), TanStack Router + Query conventions, multi-chain query strategy, cross-chain defpact UX."
---
# Web Architecture

## Three-Origin Rule

- **smartpacts.io**: Astro static site, marketing only, no wallet imports, Plausible analytics
- **app.smartpacts.io**: Stakeholder SPA, Vite React, WebHID + Chainweaver copy/paste fallback
- **admin.smartpacts.io**: Admin SPA, separate bundle, Ledger-only, Cloudflare Access gated, stricter CSP

Admin code MUST NOT appear in stakeholder bundle. Enforce via CI build-output audit.

## Layer Boundaries

- **`wallet/`**: Only place importing `@ledgerhq/*`, implements WalletAdapter interface
- **`chain/`**: Only place importing `@kadena/client`, unwraps Pact JSON responses
- **`features/`**: Vertical slices (portfolio, governance, admin), business logic
- **`ui/`**: shadcn/ui primitives + brand components
- **`store/`**: Zustand stores for UI state only

Layer violations = build error via eslint no-restricted-imports.

## @smartpacts/pact-bindings Pattern

Typed wrappers per DAO module, single source of truth for Pact function signatures:
```typescript
export const daoToken = {
  transfer: ({ from, to, amount, chainId }: TransferArgs) => IUnsignedCommand,
  getBalance: ({ account, chainId }: BalanceArgs) => IPactCommand
}
```

Generated from .pact module signatures, not hand-written.

## Multi-Chain Query Strategy

- Query keys: `['balance', account, chainId]` - always include chainId
- 20-chain parallel fan-out via TanStack `useQueries`
- Partial-result rendering with progress indicators
- Failed chain queries don't block successful ones
- Cache per-chain, invalidate selectively on transfers

## Cross-Chain UX Pattern

- **Hub-locked buy**: Always chain 0, no picker
- **Same-chain transfer**: Auto-detect, single picker
- **Cross-chain transfer**: Explicit dual picker, defpact progress UI
- **Continuation persistence**: localStorage keyed by pact-id
- Source + target chain + step always visible on device AND UI

## State Split

- **Server state**: TanStack Query (balances, proposals, chain data)
- **UI state**: Zustand (wallet connection, selected chain, forms)
- **URL state**: TanStack Router search params (filters, pagination)
- **Local storage**: Non-sensitive preferences only (theme, selected account pubkey)

Never store private keys or session tokens in localStorage.

## Component Architecture

- shadcn/ui is copy-in, not dependency — pin Radix primitive versions
- No Next.js for any origin (security: no server runtime)
- No CSS-in-JS frameworks (CSP conflicts) — Tailwind covers all styling
- Brand primitives extend shadcn base components
- Every feature gets error boundary with Sentry reporting