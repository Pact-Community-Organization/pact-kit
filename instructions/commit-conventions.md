---
description: "Use when writing commit messages, PR titles, branch names, or any version control operations. Conventional commits format with agent tag prefix."
# Commit & Branch Conventions

## Commit Messages
```
[AgentName] type(scope): description

Body explaining what and why (not how).

Refs: #issue-number
```

### Types
- `feat` — New feature
- `fix` — Bug fix
- `refactor` — Code restructuring (no behavior change)
- `test` — Adding or modifying tests
- `docs` — Documentation changes
- `deploy` — Deployment configuration
- `ci` — CI/CD pipeline changes
- `chore` — Maintenance tasks

### Scopes
- `my-token`, `my-governance`, or your module names
- `ledger-core`, `ledger-cli`, `ledger-web`
- `devnet`, `testnet`, `mainnet`
- `coordination`, `agent-config`

## Branch Names
```
{type}/{issue-number}-{short-description}
```
Examples: `feat/53-dividend-accumulator`, `fix/48-voter-count-schema`

## PR Titles
```
[AgentName] type(scope): description (#issue)
```
