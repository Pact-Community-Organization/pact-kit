# Tool Support

Pact Kit is designed to work with Claude Code, Codex, and Gemini CLI.
The core content (`skills/`, `instructions/`, `commands/`, `agents/`) is shared across all hosts;
host-specific files are thin adapters that make it accessible in each tool.

## Supported Hosts

| Host | Install method | What you get |
|---|---|---|
| Claude Code | `claude plugins add Pact-Community-Organization/pact-kit` | Full install: 25 skills, 21 commands, 16 instructions, `pact-auditor` + `red-team-attacker` agents, CI scripts |
| Codex | `codex plugins add Pact-Community-Organization/pact-kit` | 25 skills, 21 commands, 16 instructions, `pact-auditor` + `red-team-attacker` agents |
| Gemini CLI | `gemini extension install https://github.com/...` | `AGENTS.md` always-on context injected into every session |
| Any host | `bash <(curl -fsSL .../scripts/install.sh)` | Full install into `~/.claude/` |

## Per-host Details

### Claude Code

Plugin adapter: `.claude-plugin/plugin.json`

Installs skills, commands, and instructions into Claude Code's native discovery paths.
The `pact-auditor` sub-agent is available as an independent reviewer — invoke it with
`security review` or `ready to ship`; the `red-team-attacker` sub-agent runs the offensive
`/red-team` pass. CI scripts install to `~/.claude/scripts/` and can be wired as `PostToolUse`
and `Stop` hooks in `~/.claude/settings.json`.

### Codex

Plugin adapter: `.codex-plugin/plugin.json`

Same skill and instruction surface as Claude Code. Commands available via Codex's command
picker. `pact-auditor` and `red-team-attacker` available as sub-agents.

### Gemini CLI

Extension adapter: `gemini-extension.json` (sets `contextFileName: "AGENTS.md"`)

The `AGENTS.md` at the repo root is injected as always-on context into every Gemini CLI
session. It carries the non-negotiables (static analysis gate, gas ceiling, ADR discipline,
minimal-first rule) and a catalog of available skills and the `pact-auditor` and
`red-team-attacker` agents.

Skills and commands are not natively discovered by Gemini CLI — reference them manually
from `~/.claude/skills/` and `~/.claude/commands/` after running the curl-pipe installer.

### Any host — curl-pipe installer

`scripts/install.sh` copies the full package into `~/.claude/`:

```
~/.claude/
  skills/           25 domain skill files
  instructions/     16 behavioral instruction files
  commands/         21 slash command files
  agents/
    pact-auditor.md
    red-team-attacker.md
  scripts/
    pact-static-check.sh
    session-end-secrets-scan.sh
  CLAUDE.md.template
```

The installer merges — it never deletes existing files. Run it again after updates.

## AGENTS.md — Universal Fallback

`AGENTS.md` at the repository root is the universal fallback for any agent host that reads it
automatically. It is picked up without any plugin install by: Gemini CLI, Cursor, Windsurf,
Antigravity, CodeWhale, Swival, VS Code + Codex extension, and Kiro (as a steering rule).

Copy it into any Pact project root to get the non-negotiables without installing the full package:

```bash
curl -fsSL https://raw.githubusercontent.com/Pact-Community-Organization/pact-kit/main/AGENTS.md \
  > /path/to/your-project/AGENTS.md
```
