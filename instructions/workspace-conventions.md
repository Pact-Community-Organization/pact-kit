---
description: "Workspace conventions, file organization, naming patterns, and project structure for Pact/KDA-CE development with Claude Code."
---
# Workspace Conventions

> **MANDATORY before creating any file/dir.** Check the per-project CLAUDE.md module inventory and ADR index first to avoid duplication.

## Claude Code Layout

- `~/.claude/CLAUDE.md` — global rules (always loaded).
- `../agents/` — sub-agents (`*.md`, e.g. `pact-auditor.md`).
- `` — reference instructions (read on demand).
- `../skills/` — domain skill references (read on demand).
- `../commands/` — slash commands (`<name>.md` → `/name`).

## Project Layout

```
<project>/
  CLAUDE.md              — project identity, module inventory, ADR index (≤150 lines)
  STATUS.md              — current sprint state (≤50 lines, replace not append)
  .claude/
    settings.json        — hooks (session-end secrets scan, static check gate)
  .github/
    scripts/
      pact-static-check.sh          — CI static analysis gate
      session-end-secrets-scan.sh   — secrets scan hook
    workflows/
      pact-ci.yml                   — GitHub Actions CI
  pact/
    modules/             — Pact contracts (*.pact)
    interfaces/          — Pact interfaces (*.pact)
    tests/               — REPL tests (*.repl)
    deploy/              — deploy transactions / keyset config
  ts/
    src/                 — TypeScript client/integration code
    scripts/             — deploy/seed/diagnostic scripts
    tests/               — devnet integration tests
  docs/
    adr/                 — ADR-NNN-kebab-name.md files
    processes/           — PROC-NNN-kebab-name.md runbooks
```

## File Placement Rules

| File type | Location |
|---|---|
| Pact contract (`.pact`) | `pact/modules/` |
| Pact interface (`.pact`) | `pact/interfaces/` |
| Pact REPL test (`.repl`) | `pact/tests/` |
| TS deploy/seed script | `ts/scripts/` |
| TS devnet/integration test | `ts/tests/` |
| ADR | `docs/adr/ADR-NNN-name.md` |
| Process/runbook | `docs/processes/PROC-NNN-name.md` |
| Architecture/API doc | `docs/` |
| Claude Code skill | `../skills/<name>.md` |
| Claude Code instruction | `<name>.md` |
| Claude Code command | `../commands/<name>.md` |
| Claude Code agent | `../agents/<name>.md` |

## Anti-Duplication Rules
1. Check per-project CLAUDE.md module inventory before creating any new module.
2. Check `docs/adr/` ADR index before any architecture decision — an ADR may already exist.
3. Keep status in one place: `STATUS.md` at project root. No scattered `TODO.md`/`NOTES.md`.
4. Single ADR index only — the table in per-project CLAUDE.md.
5. Keep debug/temp files out of tracked module folders; delete when done.
6. Runtime artifacts (`.log`, `.pid`, `*.key`) are gitignored — never commit them.

## Naming Conventions

| Artifact | Pattern | Example |
|---|---|---|
| Pact module | `kebab-name.pact` | `spt-token.pact` |
| Pact REPL test | `kebab-name.repl` | `spt-token.repl` |
| TypeScript test | `kebab-scope-description.test.ts` | `dividend-conservation.test.ts` |
| ADR | `ADR-NNN-kebab-name.md` | `ADR-001-token-standard.md` |
| Process runbook | `PROC-NNN-kebab-name.md` | `PROC-001-devnet-deploy.md` |
| Claude Code command | `kebab-name.md` | `design-defpact.md` |
| Claude Code agent | `kebab-name.md` | `pact-auditor.md` |
| Docker compose | `docker-compose.yml` | single devnet per project |
