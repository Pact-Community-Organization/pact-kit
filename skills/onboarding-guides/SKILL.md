---
name: onboarding-guides
description: "Developer onboarding and quickstart guides for Pact Community. Setup instructions, development workflow, and getting-started documentation for new contributors."
---
# Onboarding Guides

## Quickstart Template
```markdown
# Getting Started with {Project}

## Prerequisites
- Node.js >= 18
- Docker Desktop
- pnpm
- VS Code with GitHub Copilot

## Setup
1. Clone the repository
2. Install dependencies: `pnpm install`
3. Start devnet: `docker compose -f docker-compose.developer.yml up -d`
4. Wait for health: `curl http://localhost:8081/info`
5. Deploy contracts: `npx tsx pact-examples/pact/deploy/deploy-all.ts`
6. Run tests: `npx vitest`

## Development Workflow
1. Create branch: `feat/{issue}-{description}`
2. Implement changes
3. Run REPL tests: `pact pact-examples/pact/tests/{module}.repl`
4. Run devnet tests: `npx vitest`
5. Create PR with `[Developer]` prefix
6. Wait for Tester + Security review
```

## Key Concepts for New Contributors
- Pact 5 basics and critical traps
- KDA-CE architecture (20-chain, gas limits)
- Multi-agent workflow (feature → design → build → test → deploy)
- Quality gate requirements
