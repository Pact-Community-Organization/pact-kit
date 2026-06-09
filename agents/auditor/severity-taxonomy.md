# Audit Finding Severity Taxonomy

This document defines the severity classification system for Pact Community third-party audits, with specific criteria, examples, and decision guidelines.

## Severity Matrix

Severity is determined by combining **Impact** and **Likelihood** assessments:

| Impact → | **High** | **Medium** | **Low** |
|----------|----------|------------|---------|
| **High Likelihood** | CRITICAL | HIGH | MEDIUM |
| **Medium Likelihood** | HIGH | MEDIUM | LOW |  
| **Low Likelihood** | MEDIUM | LOW | INFORMATIONAL |

## Impact Assessment

### High Impact
- **Direct fund loss**: User or treasury funds can be stolen, locked, or destroyed
- **Governance takeover**: Malicious control of protocol administration or voting
- **Total system compromise**: Protocol becomes permanently unusable
- **Massive user data exposure**: Private keys, personal information, or financial data leaked

**Examples:**
- Token draining exploits  
- Admin key compromise vulnerabilities
- Vote buying or manipulation enabling governance takeover
- Cross-chain fund redirections

### Medium Impact  
- **Partial fund loss**: Limited theft or user/treasury fund exposure
- **Temporary system disruption**: Protocol can be restored but with significant effort
- **Economic manipulation**: Unfair advantage but not total system compromise
- **Moderate data exposure**: Non-sensitive user information leaked

**Examples:**
- Unbounded gas consumption causing temporary DoS
- Dividend calculation errors affecting distributions
- Vote weight manipulation without full governance control
- Upgrade process vulnerabilities requiring manual intervention

### Low Impact
- **Minor economic effects**: Small financial advantage or inefficiency
- **Limited system disruption**: Temporary issues with easy recovery
- **Information disclosure**: Non-sensitive data exposure
- **Usability problems**: Poor UX but no security implications

**Examples:**
- Gas optimization opportunities
- Minor precision loss in calculations
- Event emission inconsistencies
- Error message information leakage

## Likelihood Assessment

### High Likelihood
- **Trivial to exploit**: Simple transaction sequence or common tools required
- **No special permissions**: Any user can execute the attack
- **No economic barriers**: Low cost to execute
- **Publicly discoverable**: Vulnerability easily found through static analysis

**Indicators:**
- Single transaction exploit
- No admin capabilities required
- Obvious in source code
- Standard attack patterns

### Medium Likelihood
- **Moderate complexity**: Requires specific timing, state, or advanced tools
- **Some barriers**: Economic cost, race conditions, or specific privileges needed
- **Non-obvious**: Requires careful analysis or domain expertise to discover
- **Limited attack windows**: Specific conditions must be met

**Indicators:**
- Multi-step exploit sequence
- Requires specific contract state
- Moderate economic cost to execute
- Timing-dependent attacks

### Low Likelihood  
- **High complexity**: Requires significant resources, advanced skills, or rare conditions
- **Strong barriers**: High economic cost, administrative access, or perfect timing
- **Hidden**: Requires deep protocol knowledge and sophisticated analysis
- **Theoretical**: Exploit path exists but practically difficult

**Indicators:**
- Complex exploit requiring precise coordination
- High economic cost to execute profitably  
- Requires advanced blockchain or cryptographic expertise
- Dependent on multiple external factors

## Severity Definitions

### CRITICAL
- **Criteria**: High Impact + High Likelihood
- **Deployment Impact**: BLOCKS deployment completely
- **Remediation Timeline**: Immediate (within 24-48 hours)
- **Examples**:
  - Unguarded token minting functions
  - pact-id as sole authorization guard
  - Cross-module capability bypass
  - Treasury drain via arithmetic overflow

**Decision Criteria:**
- Can ordinary users steal significant funds?
- Can attackers gain admin control easily?
- Would exploit cause immediate total system failure?

### HIGH  
- **Criteria**: (High Impact + Medium Likelihood) OR (Medium Impact + High Likelihood)
- **Deployment Impact**: Requires remediation plan with timeline before deployment
- **Remediation Timeline**: 1-2 weeks maximum
- **Examples**:
  - Gas exhaustion DoS attacks
  - Vote manipulation requiring significant stake
  - Cross-chain continuation vulnerabilities
  - Keyset upgrade process flaws

**Decision Criteria:**
- Would exploit require moderate resources but cause significant damage?
- Could sophisticated attackers gain unfair advantage?
- Would exploit disrupt normal operations significantly?

### MEDIUM
- **Criteria**: Various Impact-community/Likelihood combinations not qualifying as HIGH or higher
- **Deployment Impact**: Should be addressed but may be accepted with documentation
- **Remediation Timeline**: Next development sprint (2-4 weeks)
- **Examples**:
  - Inefficient gas usage patterns
  - Minor precision loss in calculations
  - Event emission gaps
  - Error handling improvements

**Decision Criteria:**
- Would exploit cause minor financial loss or advantage?
- Does finding improve security posture without critical urgency?
- Can risk be mitigated through documentation and monitoring?

### LOW
- **Criteria**: (Medium Impact + Low Likelihood) OR (Low Impact + Medium Likelihood)
- **Deployment Impact**: Address when convenient
- **Remediation Timeline**: Future development cycles (1-3 months)
- **Examples**:
  - Code style inconsistencies affecting security review
  - Missing @doc annotations on security-relevant functions
  - Suboptimal error messages
  - Performance optimizations

**Decision Criteria:**
- Does finding improve code quality without immediate security impact?
- Would fix prevent future security issues?
- Is impact primarily on maintainability or usability?

### INFORMATIONAL
- **Criteria**: (Low Impact + Low Likelihood) OR educational observations
- **Deployment Impact**: No blocking impact
- **Remediation Timeline**: Optional
- **Examples**:
  - Best practice recommendations
  - Future upgrade considerations
  - Design pattern suggestions
  - Compliance observations

**Decision Criteria:**
- Does finding provide valuable insight without immediate action required?
- Would information help future development or audits?
- Are there industry best practices not currently followed?

## Severity Modifiers

### Upgrading Severity
Increase severity by one level if:
- **Multiple instances**: Pattern repeated across codebase
- **Combination risk**: Low-severity issues combine to create higher risks
- **Trend amplification**: Issue likely to worsen over time
- **Critical asset exposure**: Financial systems, governance, or core protocol functionality

### Downgrading Severity
Decrease severity by one level if:
- **Strong mitigations**: Existing protections significantly reduce risk
- **Limited exposure**: Issue affects small subset of functionality
- **Economic infeasibility**: Attack costs exceed potential benefits
- **Existing monitoring**: Systems in place to detect and respond to exploitation

### External Factors
Consider but don't automatically change severity:
- **Regulatory requirements**: Compliance needs may elevate priority
- **Time sensitivity**: Imminent deployments may require faster remediation
- **Public disclosure**: Risk of copycat attacks may increase urgency
- **Business impact**: Reputation or partnership effects

## Special Considerations for Pact 5 / KDA-CE

### Critical Pact 5 Patterns (Always HIGH or CRITICAL)
- **Read-only context violations**: DML in `try` blocks or `enforce` arguments
- **pact-id authorization**: Using `pact-id` as sole guard instead of capabilities
- **Binary operator errors**: Incorrect use of `+` with multiple arguments
- **@managed capability violations**: install-capability outside with-capability
- **Cross-module trust failures**: Inappropriate assumptions about other modules

### KDA-CE Specific High-Risk Areas
- **Gas limit violations**: Operations exceeding 150k gas
- **Cross-chain security**: defpact continuation vulnerabilities
- **Namespace violations**: Hardcoded namespace usage
- **Keyset governance**: Improper admin key management
- **SPV proof handling**: Cross-chain verification bypass

### Economic Exploit Vectors (Context-Dependent Severity)
- **Governance attacks**: Vote buying, proposal manipulation, admin takeover
- **Economic arbitrage**: Unfair advantage in token operations
- **MEV opportunities**: Extractable value from transaction ordering
- **Oracle manipulation**: Price or data feed attacks
- **Flash loan attacks**: Uncollateralized position manipulation

## Verdict Determination

### PASS
- Zero CRITICAL findings
- Zero HIGH findings
- All MEDIUM findings acknowledged with acceptable risk or remediation plan
- LOW and INFORMATIONAL findings documented

### CONDITIONAL PASS
- Zero CRITICAL findings  
- HIGH findings have documented remediation plan with specific timeline (≤ 2 weeks)
- MEDIUM findings acknowledged with risk acceptance or timeline
- Explicit stakeholder approval of risk acceptance

### FAIL
- Any unresolved CRITICAL findings
- HIGH findings without acceptable remediation plan
- MEDIUM findings without risk acceptance or timeline
- Stakeholder unwillingness to accept identified risks

## Documentation Requirements

### Each Finding MUST Include:
- **Specific severity with justification**: Impact + Likelihood reasoning
- **Code evidence**: File:line references with excerpts
- **Exploit proof**: REPL or devnet demonstration where possible
- **Impact analysis**: Detailed explanation of potential consequences
- **Remediation guidance**: Specific technical recommendations
- **Status tracking**: Open/Acknowledged/Fixed/Verified/Won't Fix

### Severity Appeals Process:
1. **Clear justification required**: Specific technical reasoning for severity change
2. **Evidence-based**: Additional code analysis or exploit scenarios
3. **Stakeholder discussion**: Risk tolerance and business impact consideration
4. **Documented decision**: Final severity with complete rationale
5. **Audit trail maintenance**: Record of all discussions and decisions

## Examples by Category

### CRITICAL Finding Example
```
AUD-001: Unguarded Treasury Drain

Severity: CRITICAL (High Impact + High Likelihood)
- Impact: HIGH (Complete treasury fund loss - $500K+ at risk)
- Likelihood: HIGH (Single transaction, no authentication required)

Location: distribution-module.pact:89
Evidence: `(coin.transfer-create treasury account guard amount)` 
Code lacks capability guard - any user can drain treasury.

Exploit: `(distribution-module.claim-dividend "attacker" 1000000.0)`
PoC: Verified on devnet - drained entire treasury in one transaction
```

### HIGH Finding Example
```
AUD-007: Vote Weight Manipulation

Severity: HIGH (High Impact + Medium Likelihood) 
- Impact: HIGH (Governance takeover possible)
- Likelihood: MEDIUM (Requires significant stake and timing)

Location: governance-voting.pact:156
Evidence: Vote weight not properly validated against token balance
Exploit requires purchasing 30%+ stake but enables permanent control.
```

### MEDIUM Finding Example
```
AUD-015: Gas Inefficient Select Query

Severity: MEDIUM (Medium Impact + Medium Likelihood)
- Impact: MEDIUM (DoS potential under high load)  
- Likelihood: MEDIUM (Requires coordinated transaction volume)

Location: governance-token.pact:234
Evidence: `(select token-table (constantly true))` unbounded
Could consume excessive gas or hit 150k limit during high activity.
```