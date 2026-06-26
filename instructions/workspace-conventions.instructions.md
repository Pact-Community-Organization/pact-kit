---
description: "Use for general workspace conventions, file organization, naming patterns, and project structure when using this agent system."
applyTo: "**"
---
# Workspace Conventions

> **MANDATORY before creating any file/dir.** If your project keeps a file registry, check it first.

> These are recommended conventions for organizing a Pact project that uses this `.github/` agent system. Adapt the paths to your repository — the only fixed requirement is the `.github/` layout below.

## `.github/` Layout (fixed)

- `.github/copilot-instructions.md` — always-on router prompt.
- `.github/agents/` — agent definitions (`*.agent.md`).
- `.github/instructions/` — behavioral rules (`*.instructions.md`, `applyTo`-scoped).
- `.github/skills/` — domain skills (`<skill-name>/SKILL.md`).
- `.github/prompts/` — reusable prompts (`*.prompt.md`).
- `.github/hooks/` — Copilot hook JSON.
- `.github/scripts/` — hook runtime scripts (if used).

## Recommended Project Structure

Organize your repository however suits the project; a common layout is:

- `pact/modules/` — Pact modules (`*.pact`).
- `pact/interfaces/` — Pact interfaces.
- `pact/tests/` — REPL tests (`*.repl`).
- `pact/deploy/` — deploy transactions / keyset config.
- `ts/src/` — TypeScript client/integration code.
- `ts/scripts/` — deploy/seed/diagnostic scripts.
- `ts/tests/` — integration/devnet tests.
- `docs/` — project documentation (ADRs, processes, API, architecture).
- an archive/history folder (give each archived area a `README.md`).

### Optional coordination convention

If you run a multi-agent workflow, a lightweight coordination area can help keep state in one place:

- A session-start memory entry point, status note, file registry, append-only session log, and supporting domain notes.
- Task queues, per-agent mailboxes, status dashboards, and agent reports can live alongside that convention if you use one.

## File Placement Rules

| File type | Recommended location |
|-----------|----------------------|
| Pact contract (`.pact`) | `pact/modules/` |
| Pact REPL test (`.repl`) | `pact/tests/` |
| TS deploy/seed script | `ts/scripts/` |
| TS devnet/integration test | `ts/tests/` |
| ADR | `docs/adr/ADR-0NN-name.md` |
| Process/runbook (`PROC-*`) | `docs/processes/` |
| Architecture/API doc | `docs/` |
| Agent behavioral rule | `.github/instructions/topic.instructions.md` |
| Agent skill | `.github/skills/skill-name/SKILL.md` |
| Agent prompt | `.github/prompts/action.prompt.md` |
| Agent definition | `.github/agents/Name.agent.md` |
| Archived/obsolete content | an optional archive area with a README |

### Anti-duplication rules
1. If you keep a file registry, check it before creating any doc; UPDATE the canonical file if it already exists.
2. Avoid scattering `STATUS.md`/`TODO.md`/`NOTES.md` across the tree — keep status in one place (e.g. `docs/memory/`).
3. Keep a single ADR index (e.g. `docs/adr/INDEX.md`).
4. Keep debug/temp files out of tracked module folders; archive or delete them when done.
5. Runtime artifacts (`.log`, `.pid`) should be gitignored — never commit them.

## Naming Conventions

| Artifact | Pattern | Example |
|----------|---------|---------|
| Instructions file | `{topic}.instructions.md` | `pact-rules.instructions.md` |
| Skill | `{skill-name}/SKILL.md` | `pact-repl-testing/SKILL.md` |
| Prompt | `{action}.prompt.md` | `deploy-module.prompt.md` |
| Agent | `{AgentName}.agent.md` | `Developer.agent.md` |
| ADR | `ADR-{NNN}-{kebab-name}.md` | `ADR-001-module-architecture.md` |
| Process | `PROC-{NNN}-{kebab-name}.md` | `PROC-001-devnet-deploy.md` |
| Devnet compose | `docker-compose.{name}.yml` | `docker-compose.tester.yml` |
| Test file | `{scope}-{description}.test.ts` | `dividend-conservation.test.ts` |
