# Auditor — Report Templates

Canonical output templates for `[Auditor]` audit reports. Load in Phase 6 (Report Generation). The detailed finding format aligns with [finding-schema.json](finding-schema.json); severity uses [severity-taxonomy.md](severity-taxonomy.md).

## Executive Summary (Always First)
```
[Auditor] AUDIT REPORT — {scope}
Date: {YYYY-MM-DD}
Commit: {hash}
Auditor: {engagement_id}

EXECUTIVE SUMMARY:
• {1-3 bullet summary of overall security posture}

FINDINGS SUMMARY: 
• CRITICAL: {count} | HIGH: {count} | MEDIUM: {count} | LOW: {count} | INFORMATIONAL: {count}

VERDICT: [Auditor] [PASS | CONDITIONAL PASS | FAIL]
RATIONALE: {brief explanation of verdict reasoning}
```

## Findings Table (Markdown)
```markdown
| Finding ID | Title | Severity | Category | Impact | Likelihood | Status |
|------------|-------|----------|----------|---------|------------|--------|
| AUD-001    | {title} | CRITICAL | {category} | High | High | Open |
| AUD-002    | {title} | HIGH     | {category} | High | Medium | Open |
```

## Detailed Finding Format
```
### AUD-{NNN}: {Title}

**Severity**: CRITICAL | HIGH | MEDIUM | LOW | INFORMATIONAL
**Category**: {STRIDE category or functional area}
**Likelihood**: High | Medium | Low  
**Impact**: High | Medium | Low
**Location**: {file:line or "Multiple files"}

**Description**:
{Clear explanation of what is wrong}

**Impact Analysis**: 
{Detailed explanation of what could happen if exploited}

**Exploit Steps**:
1. {Step-by-step attack scenario}
2. {Each step should be actionable}
3. {Include specific function calls, parameters}

**Affected Files**:
- {file_path}:{line_number}
- {file_path}:{line_range}

**Evidence**:
```pact
{Code snippet demonstrating the vulnerability}
```

**Proof of Concept**:
{REPL commands or devnet transaction demonstrating exploit}

**Remediation**:
{Specific, actionable fix recommendations}

**Status**: Open | Acknowledged | Fixed | Verified | Won't Fix | Requires Evidence
```

## Remediation Checklist (Prioritized)
```
## Remediation Checklist (Priority Order)

### CRITICAL (Block Deployment)
1. [ ] AUD-001: {brief fix description} — {estimated effort}
2. [ ] AUD-003: {brief fix description} — {estimated effort}

### HIGH (Address Before Production)  
3. [ ] AUD-002: {brief fix description} — {estimated effort}
4. [ ] AUD-005: {brief fix description} — {estimated effort}

### MEDIUM (Address in Next Sprint)
5. [ ] AUD-004: {brief fix description} — {estimated effort}

### LOW (Address When Convenient)
6. [ ] AUD-006: {brief fix description} — {estimated effort}
```

## Re-check Verification Steps
```
## Post-Remediation Verification

After remediation commit {hash}:

1. **Re-verify AUD-001**: 
   - [ ] Code review: {specific check}
   - [ ] REPL test: {command}  
   - [ ] Devnet test: {scenario}

2. **Re-verify AUD-002**:
   - [ ] {specific verification steps}

3. **Full Regression**:
   - [ ] Run complete REPL test suite
   - [ ] Deploy to devnet and run integration tests
   - [ ] Verify no new issues introduced

4. **Updated Verdict**: [PASS | CONDITIONAL PASS | FAIL]
```
