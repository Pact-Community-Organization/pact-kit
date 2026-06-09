---
name: release-management
description: "Versioning, tagging, and release notes for Pact 5 smart contracts and TypeScript packages. Semantic versioning, CHANGELOG management, and release checklist."
---
# Release Management

## Semantic Versioning
- `MAJOR.MINOR.PATCH` (e.g., 1.2.3)
- MAJOR: breaking interface changes
- MINOR: new features, backward compatible
- PATCH: bug fixes, no new features

## Release Checklist
- [ ] All Gate 2 criteria passed (Tester GO, Security APPROVE)
- [ ] CHANGELOG.md updated with all changes
- [ ] Version bumped in relevant package.json -community/ module metadata
- [ ] Git tag created: `v{MAJOR}.{MINOR}.{PATCH}`
- [ ] Testnet deployment successful
- [ ] Gas measurements documented
- [ ] API documentation up to date
- [ ] Migration guide written (if breaking changes)

## CHANGELOG Format
```markdown
## [v1.2.0] - 2026-04-12
### Added
- New dividend claim function (#45)
### Changed
- Updated gas estimates for governance-voting (#46)
### Fixed
- Voter count tracking in tally schema (#48)
### Security
- Fixed capability composition gap (#49)
```

## Tag Naming
- Smart contracts: `governance-v1.2.0`, `ledger-v0.3.0`
- TypeScript packages: follows package.json version
