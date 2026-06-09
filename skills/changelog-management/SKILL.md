---
name: changelog-management
description: "CHANGELOG maintenance, version history tracking, and release notes generation. Keep a Changelog format for Pact modules and TypeScript packages."
---
# Changelog Management

## Format (Keep a Changelog)
```markdown
# Changelog
All notable changes to this project.

## [Unreleased]
### Added
- New feature

## [v1.0.0] - 2026-04-12
### Added
- Initial release
```

## Categories
- **Added** — New features
- **Changed** — Modified existing functionality
- **Deprecated** — Soon-to-be-removed features
- **Removed** — Deleted features
- **Fixed** — Bug fixes
- **Security** — Vulnerability fixes

## Rules
- Every PR adds a changelog entry
- Entries reference issue/PR number
- Use past tense for completed work
- Security entries get special attention
- Group entries by module when applicable
