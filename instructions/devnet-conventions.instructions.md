---
description: "Use when working with KDA-CE devnet, configuring Docker containers, writing devnet tests, or troubleshooting devnet infrastructure. Covers ports, toolchain, timing, and type unwrapping."
applyTo: ["pact-examples/ts/tests/devnet/**", "pact-examples/docker-compose.*"]
# Devnet Conventions

## Port Assignment

| Agent | Port | Docker Compose | Container |
|-------|------|---------------|-----------|
| Developer | 8081 | docker-compose.developer.yml | devnet-developer |
| Tester | 8082 | docker-compose.tester.yml | devnet-tester |
| Security | 8083 | docker-compose.security.yml | devnet-security |
| Auditor | 8084 | docker-compose.auditor.yml | devnet-auditor |

## Toolchain
- **TypeScript runner**: `npx tsx` (NOT `ts-node`)
- **Test runner**: `npx vitest`
- **Host env var**: `DEVNET_HOST` (full URL, e.g., `http://localhost:8081`)

## Critical Infrastructure Rules

### Transaction Confirmation
- Use `client.pollOne({ timeout: 600_000, interval: 5_000 })` not `client.listen()`
- `listen()` → nginx 504 timeout (hard 60s, read-only nix store)

### Chain Time (CRITICAL)
- Devnet chain time runs ~2× slower than wall clock on fresh containers
- NEVER use `await wait(N)` for time-dependent tests
- ALWAYS poll chain time: fetch header, check `creationTime / 1_000_000` vs target
- Mining client catches up from genesis to wall clock in ~10-20 seconds

### Fresh Devnet Timing
- Genesis blocks have 2019 timestamps
- Using them as tx creationTime → "TTL expired"
- Using Date.now() → "creation time too far in the future"
- Fix: fetch actual chain time from header, retry until within 5 min of wall clock

### Pact API Type Unwrapping (CRITICAL)
- Integers: `{int: N}` — must unwrap before comparison
- Whole decimals: plain number (e.g., `5.0` → `5`)
- Fractional decimals: `{decimal: "N.M"}` — must unwrap
- Row keys NOT included in read results — only schema fields
- Non-existent fields → `undefined` → `NaN` → silent false positives

### Chainweb Header
- `/chain/{id}/header/{hash}` returns base64 binary by default
- Use `Accept: application/json;blockheader-encoding=object` for JSON
- `creationTime` is in **microseconds** — divide by 1,000,000

## sender00 Devnet Keypair
- Public: `368820f80c324bbc7c2b0610688a7da43e39f91d118732671cd9c7500ff43cca`
- Secret: `251a920c403ae8c8f65f59142316af3c82b631fba46ddea92ee8c95035bd2898`

## Principal Namespace
- `<namespace-principal>` (from sender00)
