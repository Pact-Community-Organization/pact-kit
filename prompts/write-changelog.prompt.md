---
description: "Docs: Generate or update CHANGELOG.md entries for a release. Follow Keep a Changelog format with proper categorization."
---
# Write Changelog

## Input
- Git commits since last release
- PR descriptions
- Issue references

## Process
1. Collect all changes since last version tag
2. Categorize: Added, Changed, Fixed, Security, Deprecated, Removed
3. Write entries with issue/PR references
4. Update version number

## Output
```markdown
## [{version}] - {YYYY-MM-DD}

### Added
- {description} (#{issue})

### Changed
- {description} (#{issue})

### Fixed
- {description} (#{issue})

### Security
- {description} (#{issue})
```

## Rules
- One entry per logical change (not per commit)
- Reference issue/PR number
- Use past tense
- Security entries are highlighted and explained
- Breaking changes clearly marked
