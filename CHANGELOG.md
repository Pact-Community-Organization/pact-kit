# Changelog

All notable changes to Pact Kit are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.0] — 2026-06-28

Initial release as a Claude Code native package.

### Package infrastructure

- `AGENTS.md` — compact always-on Pact/KDA-CE instruction set; auto-loaded by Gemini CLI,
  Cursor, Windsurf, Antigravity, CodeWhale, and any tool that reads `AGENTS.md` at the repo root
- `.claude-plugin/` — Claude Code marketplace listing and plugin definition
- `.codex-plugin/` — Codex plugin definition
- `gemini-extension.json` — Gemini CLI extension manifest pointing `contextFileName` at `AGENTS.md`
- `package.json` — npm package at `@pact-community/pact-kit` for discoverability
- `scripts/install.sh` — curl-pipe installer; copies the full package into `~/.claude/`
- `docs/agent-portability.md` — per-host install guide

### Content

- 24 Pact/KDA-CE skills in `skills/<name>.md` — flat files for on-demand loading
- 16 behavioral instruction files in `instructions/<name>.md`
- 20 slash commands in `commands/<name>.md` covering the full development lifecycle
- `agents/pact-auditor.md` — independent security reviewer; no implementation history
- `scripts/pact-static-check.sh` — Tier 1 (Pact CLI) + Tier 2 (semantic greps) static analysis gate
- `scripts/session-end-secrets-scan.sh` — session-end hook that scans modified files for credentials
- `CLAUDE.md.template` — starter global configuration with hooks snippet
- `project-templates/CLAUDE.md.project` — per-project configuration template
- `project-templates/STATUS.md.template` — sprint status template

[0.1.0]: https://github.com/Pact-Community-Organization/pact-kit/releases/tag/v0.1.0
