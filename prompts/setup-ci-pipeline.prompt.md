---
description: "DevOps: Set up or modify GitHub Actions CI/CD pipeline for Pact and TypeScript testing, devnet deployment, and quality gate enforcement."
---
# Setup CI Pipeline

## Pipeline Components
1. **REPL Tests** — Run Pact REPL tests on push/PR
2. **TypeScript Tests** — Run vitest on push/PR
3. **Static Analysis** — Check for Pact 5 traps
4. **Devnet Deploy** — Deploy and test on devnet (on approval)
5. **Gate Checks** — Enforce quality gate requirements

## Workflow Template
```yaml
name: Pact Community CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  repl-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run REPL tests
        run: |
          # Install Pact 5 CLI
          # Run all .repl test files

  typescript-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - run: pnpm install
      - run: pnpm test
```
