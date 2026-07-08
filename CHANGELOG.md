# Changelog

All notable changes to Pact Kit are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added

- **skills/red-team-testing.md** — offensive red-team method: two engines (reverse-coverage
  + invariant hunting), eight attack blocks, a 20-mutation-per-front depth standard,
  differential-oracle testing with an anti-tautology negative control, and an L1 filter that
  drops REPL-only artifacts (`test-capability`, `coin.GAS`, single-DB 20-chain sims) so a
  "held" verdict stays credible.
- **commands/red-team.md** — `/red-team`, a 5-phase protocol that *executes* real `.repl`
  attacks with the `pact` CLI; the offensive counterpart to `/full-security-audit`.
- **agents/red-team-attacker.md** — a fresh-context attacker sub-agent that sweeps one front
  with 20 mutations and reports HELD or BROKEN with reproducible proof; complements
  `pact-auditor` (which reviews).

### Changed

- Registered the three new files across the manifests and docs: skill count 24 → 25, command
  count 20 → 21, agent count 1 → 2 in `.claude-plugin/plugin.json`,
  `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, `gemini-extension.json`,
  `README.md`, `AGENTS.md`, and `docs/agent-portability.md`.
- **red-team-testing**: aligned the DB-read-in-`enforce` L1 note with the `pact-traps`
  correction (REPL-vs-node divergence, not a 4.x-vs-5.x one) and flagged the always-true
  floor sub-additivity inequality as tautological unless paired with its negative control.

## [0.2.0] — 2026-07-01

Research-driven hardening pass: every change grounded in the kda-community/pact-5
source (v5.4 / 368-file REPL test suite), the official Pact 4→5 migration guide, and
the community contract corpus (CryptoPascal31, brothers-DAO, daplcor, kda-community).

### Corrected

- **pact-traps / pact-rules / pact-auditor**: table reads inside an `enforce` condition
  pass in the Pact 5.3+ REPL but FAIL on the KDA-CE chainweb-node (devnet-verified
  2026-07-01) — the prior "let-binding no longer needed for correctness" guidance was
  REPL-only. Rule restored: always let-bind table reads before `enforce`.
- `workspace-conventions.md`: restored two `instructions/` paths lost in the kit-extraction sed.

### Added

- **pact-traps**: "Pact 4→5 migration traps" section (dependency-inclusive module hashes,
  no implicit module admin, strict `install-capability`, `{int: N}` codec, strict
  `(coin.GAS)` signing, removed natives, parser strictness, `static-redeploy`); verified
  `acquire-module-admin` semantics (rest-of-tx persistence, REPL auto-grant divergence);
  modref read-only reentrancy guard citation (upstream `reentrancy.repl`).
- **examples/** — runnable `example-token.pact` + `.repl` suite (green on pact 5.3, passes
  the static gate) demonstrating the kit's conventions; doubles as the CI fixture.
- **skills/pact/SKILL.md** — native Claude Code skill router: auto-discovered orientation
  + task index into the 24 skills / 16 instructions (the flat files are not natively
  discovered by Claude Code).
- **docs/reference-repos.md** — vetted primary sources and the idioms they agree on.
- **scripts/pact-check-hook.sh** — PostToolUse adapter: runs the static gate only on the
  edited `.pact`/`.repl` file (the raw checker full-scanned on every edit); exit 2 feeds
  violations back to the agent.
- **scripts/check-md-links.sh** — relative-markdown-link checker (CI).
- **pact-repl-testing**: community idioms — `enforce-pact-version` header, `typecheck`
  after load, module-hash print, managed-cap install-before-body test semantics,
  `expect-that` + composed predicates, stub modules, `kadena_repl_sandbox`.

### Changed

- **CI** is real now: shellcheck, markdown link check, pact 5.3 binary download, example
  REPL suite, static gate against the examples.
- **pact-static-check.sh**: new WARN grep for table reads inside `enforce` conditions;
  namespace/keyset environment errors on bare loads classified as harness-needed WARNs.
- **install.sh**: installs `project-templates/`, the hook adapter, and the skill router;
  curl-install next-steps no longer point into the deleted temp clone.

[0.2.0]: https://github.com/Pact-Community-Organization/pact-kit/releases/tag/v0.2.0

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
