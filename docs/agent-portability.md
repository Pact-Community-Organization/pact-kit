# Agent Portability

Pact Agent Marketplace is an agent-portable skill distribution. The skills in `skills/` hold
the core behavior; host-specific files are adapters that make that behavior easy to load in
a given agent host.

## Supported Hosts

| Host | Files | Install | Notes |
|------|-------|---------|-------|
| Claude Code | `.claude-plugin/plugin.json`, `skills/`, `agents/`, `instructions/`, `hooks/` | `claude plugins add Pact-Community-Organization/github-marketplace` | Full plugin install: skills auto-discovered, agents available as subagents, instructions scoped by `applyTo`. |
| Codex | `.codex-plugin/plugin.json`, `skills/`, `agents/`, `instructions/` | `codex plugins add Pact-Community-Organization/github-marketplace` | Plugin install with same skills and instructions. |
| Gemini CLI | `gemini-extension.json`, `AGENTS.md`, `skills/` | `gemini extension install https://github.com/Pact-Community-Organization/github-marketplace` | Extension manifest points `contextFileName` at `AGENTS.md` for always-on rules. Skills are auto-discovered from `skills/`. |
| GitHub Copilot | `copilot-instructions.md`, `agents/`, `skills/`, `instructions/`, `prompts/` | `bash <(curl -fsSL .../scripts/install.sh) /path/to/repo` | Copies assets into `.github/`. Copilot picks up `copilot-instructions.md` and `.github/agents/` automatically. |
| Any agent (copy-paste) | `AGENTS.md` or `skills/*/SKILL.md` | Copy the file(s) you need | `AGENTS.md` at the repo root works as always-on rules for any agent that reads it. Individual `SKILL.md` files can be copy-pasted into any skill-supporting host. |

## What Each Install Provides

### Plugin install (Claude Code / Codex)

- **Skills**: all 24 Pact/KDA-CE skills available by name via the skill picker
- **Agents**: 8 role-based agents (Developer, Tester, Architect, Security, Auditor, DevOps, Docs, Admin)
- **Instructions**: 18 instruction files — scoped automatically by `applyTo` (e.g. `*.pact`/`*.repl` triggers `pact-rules`)
- **Prompts**: 24 task prompts for architecture, implementation, review, security, and validation

### Gemini CLI extension install

- **AGENTS.md**: compact always-on Pact/KDA-CE system prompt injected into every session
- **Skills**: auto-discovered from `skills/` directory
- **No agents or hooks** at this tier — agents require manual invocation

### Copy-paste install (`scripts/install.sh`)

Everything above, installed into `TARGET/.github/`. The script copies agents, skills,
instructions, prompts, hooks, and CI scripts. Run `chmod +x .github/scripts/*.sh` after
installation.

## Adapter Rule

Keep adapters thin. When a host supports skills or hooks, point it at the existing `skills/`
and `hooks/` directories. When a host only supports project instructions, use `AGENTS.md`
as the compact fallback — it covers the non-negotiables without requiring plugin support.

## Always-on Fallback

`AGENTS.md` at the repository root is the universal fallback. It is auto-loaded by:
Gemini CLI, Cursor, Windsurf, Antigravity, CodeWhale, Swival, VS Code + Codex extension,
Kiro (as a steering rule), and any agent that respects the `AGENTS.md` convention.

Copy it into any project to get Pact/KDA-CE context without installing the full bundle.
