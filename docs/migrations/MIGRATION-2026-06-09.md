# Migration Note (2026-06-09)

Imported from local source:
- enterprise/.github/agents
- enterprise/.github/instructions
- enterprise/.github/skills
- enterprise/.github/prompts
- enterprise/.github/hooks
- enterprise/.github/copilot-instructions.md

Sanitization performed:
- Replaced Pact Community branding with neutral Pact Community language
- Removed enterprise-local filesystem references
- Rewrote internal coordination memory references to generic repository documentation references
- Replaced internal project ownership/path assumptions (DAO/Ledger/Website enterprise-specific paths)

Excluded as enterprise-private or out of scope:
- enterprise/.github/workflows
- enterprise/.github/scripts
- enterprise/.github/ARCHITECTURE-AUDIT.md
- enterprise/.github/AGENTS.md

Post-migration checks run:
- Forbidden string scan on community-facing docs/config content
- Repository structure validation
