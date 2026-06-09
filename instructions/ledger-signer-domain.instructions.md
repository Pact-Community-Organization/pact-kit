---
description: "Use when working on the Ledger Signer project — TypeScript monorepo for Kadena Ledger hardware wallet integration. Covers packages, architecture, and signing flow."
applyTo: ["ledger-examples/**"]
---
# Ledger Signer Domain Knowledge

## Package Architecture (pnpm monorepo)
- `packages/core` — Core signing logic, Ledger transport abstraction
- `packages/cli` — CLI tool for command-line signing
- `packages/web` — Web interface for browser-based signing

## Signing Flow
1. Connect to Ledger device via transport (USB/Bluetooth)
2. Select Kadena app on Ledger
3. Build unsigned transaction
4. Send transaction bytes to Ledger for signing
5. Receive signature from Ledger
6. Attach signature to transaction
7. Submit signed transaction to chainweb node

## Build & Test
```bash
pnpm install           # Install dependencies
pnpm build             # Build all packages
pnpm test              # Run all tests
pnpm --filter core test  # Test core package only
```

## Key Constraints
- Must work with Kadena Ledger app (chain-specific derivation paths)
- Transactions must be serialized in Kadena's expected format
- Support multiple chains (0-19)
- Handle connection lifecycle (connect/disconnect/reconnect)
