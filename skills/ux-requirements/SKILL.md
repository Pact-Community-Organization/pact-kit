---
name: ux-requirements
description: "UX requirements analysis for Pact Community web — INVEST user stories, persona-driven flows, Given/When/Then AC tied to Playwright tests, performance budgets, browser-support constraints for WebHID."
---
# UX Requirements

## Two Personas

**Stakeholder** (public):
- Uses Ledger hardware wallet OR Chainweaver copy/paste fallback
- Needs: buy tokens, transfer, vote, claim dividends, view portfolio
- Browser: Chrome/Edge/Opera (WebHID) or Firefox/Safari (fallback)

**Admin** (Cloudflare Access gated):
- Ledger-only, no fallback options
- Needs: declare dividend, emergency ops, view tally, manage config
- Browser: Chrome/Edge/Opera required (WebHID mandatory)

## User Story Template

```
As a [persona]
I want [goal]
So that [business value]

Acceptance Criteria:
Given [context]
When [action]  
Then [expected result]

Out of Scope: [explicit exclusions]
```

INVEST Checklist: Independent, Negotiable, Valuable, Estimable, Small, Testable.

## Acceptance Criteria Rules

- Must be Given/When/Then format
- Must be directly callable from Playwright (include selector hints)
- Expected state must be verifiable via DOM assertions
- Every success path needs corresponding failure path
- No implementation details in AC (what, not how)

Example:
```
Given stakeholder on portfolio page
When clicks "Transfer" on chain 5 balance row  
Then transfer form opens with source chain pre-filled as "5"
And destination chain picker shows chains 0-19 except 5
And amount field shows max = current chain 5 balance
```

## Performance Budgets (Non-Functional Requirements)

- **LCP** ≤ 2.5s on 3G connection
- **TTI** ≤ 3.5s 
- **Balance load** across 20 chains ≤ 15s with progress indicators
- **Bundle size** stakeholder app ≤ 1MB gzipped, admin app ≤ 800KB
- **WCAG 2.1 AA** compliance on all forms and signing UIs

## Browser Support Constraints

**WebHID compatibility**:
- Chrome 89+, Edge 89+, Opera 75+ (full features)
- Firefox, Safari (copy/paste fallback UX only)
- Mobile browsers (view-only, no signing)

Feature detection required. Graceful degradation, not feature gating.

## Edge Case Coverage Requirements

Every feature MUST handle:
- **Ledger disconnect** mid-signing → graceful retry without double-spend
- **Chainweaver popup blocked** → clear instructions, retry button
- **Cross-chain mid-defpact** → continuation persisted to localStorage
- **Vote during transfer** → auto-adjustment warning displayed
- **Multi-chain dividend claim** → progress across chains, partial failure handling
- **Network switch** mid-session → confirmation required, state cleared

## MoSCoW Decomposition

Even "all in MVP" gets decomposed:
- **Must**: Core signing flows, basic portfolio view
- **Should**: Multi-chain progress indicators, error recovery  
- **Could**: Advanced filters, performance optimizations
- **Won't**: Full Chainweaver integration (deferred to v1.1)

## Out-of-Scope Explicit List

Prevents scope creep:
- Mobile signing (view-only acceptable)
- Chainweaver full integration (copy/paste only in MVP)
- Multi-sig workflows
- Custom token support beyond DAO token
- Dark mode (single theme in MVP)
- Keyboard navigation beyond basic tab order