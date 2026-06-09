---
description: "Use when writing documentation, API references, changelogs, README files, or onboarding guides. Standards for all documentation produced in Pact Community projects."
applyTo: ["pact-examples/docs/**/*.md", "web-examples/docs/**/*.md", ".github/**/*.md", "**/README.md", "**/CHANGELOG.md"]
# Documentation Standards

## API Documentation
- Every public function: signature, parameters, return type, example
- Capability requirements listed per function
- Gas consumption noted where measured
- Organized by module in deploy order

## Changelog Format (Keep a Changelog)
```markdown
## [vX.Y.Z] - YYYY-MM-DD
### Added
- New feature description (#issue)
### Changed
- Modified behavior (#issue)
### Fixed
- Bug fix description (#issue)
### Security
- Security fix description (#issue)
```

## ADR Format
```markdown
# ADR-{NNN}: {Title}
Status: Proposed | Accepted | Deprecated | Superseded
Date: YYYY-MM-DD
Context: {why}
Decision: {what}
Consequences: {trade-offs}
```

## README Requirements
- Project description and purpose
- Quick start instructions
- Architecture overview (with Mermaid diagram)
- Build and test commands
- Deployment instructions
- Agent interaction model

## Mermaid Diagrams
- Use for module relationships, data flow, capability hierarchies
- Keep diagrams focused — one concept per diagram
- Use consistent color scheme per agent
