---
name: web-e2e-testing
description: "End-to-end testing for Pact Community web — Playwright against live devnet, MSW for unit-level chainweb mocks, adversarial DOM-tamper tests, WebHID mock transport, cross-origin isolation verification."
---
# Web E2E Testing

## Playwright Against Live Devnet

**Target environment**: devnet:8081 for all happy path flows
**Test scope**: Stakeholder + admin origins against same devnet instance
**Browser matrix**: Chromium (primary), Firefox, Safari (fallback UX verification)

**Core flows to cover**:
- Buy tokens → transfer → vote → claim dividend (full lifecycle)
- Cross-chain transfer with defpact continuation
- Admin: declare dividend → broadcast → verify stakeholder can claim
- Ledger signing workflow (with mock transport)
- Chainweaver copy/paste fallback workflow

## Mock Ledger Transport for CI

**Deterministic mock** for CI environments:
```typescript
const MockTransport = {
  getPublicKey: () => Promise.resolve('368820f80c324bbc...'),
  signTransaction: (tx) => Promise.resolve(mockSignature),
  signContinuation: (cont) => Promise.resolve(mockSignature)
};
```

**Real device tests**: Manual/staging only (deterministic results not possible)
**Signature replay**: Pre-recorded valid signatures for devnet sender00

## MSW for Unit-Level Chainweb Mocks

**Mock scenarios**:
- Pact response unwrapping: `{int:5}` and `{decimal:"5.0"}` → assert decode.ts correctly unwraps
- Network timeout simulation: long delays → assert pollOne timeout handling
- Invalid JSON responses → assert error boundaries catch gracefully
- Chain-specific failures → assert partial success handling in multi-chain queries

## Adversarial Test Suite (Gate 2 Required)

### DOM Tamper Tests

**Transaction field modification**:
1. Render transaction preview with recipient "alice"
2. Use Playwright to modify DOM: `page.locator('[data-testid="recipient"]').fill('bob')`
3. Submit transaction  
4. Assert: Real device shows "alice" (original) OR mock transport rejects tampered payload

### Admin Bundle Leak Detection

**CI build audit**:
```bash
# In stakeholder app CI
npm run build
grep -r "AdminPage\|admin-route\|AdminComponent" dist/ && exit 1 || echo "✓ No admin leakage"
```

### postMessage Fuzzing

**Chainweaver adapter security**:
```typescript
// Wrong origin attack
window.postMessage({ type: 'sign-response', body: {...} }, 'https://evil.com');
// Assert: Adapter rejects wrong origin

// Malformed payload attack  
window.postMessage({ type: 'sign-response', body: null }, '*');
// Assert: Adapter validates with Zod, rejects invalid
```

### Cross-Chain Continuation Interrupt

**Tab close resilience**:
1. Start cross-chain transfer (generates pact-id)
2. Kill browser tab mid-defpact
3. Reopen app, navigate to transfers
4. Assert: Continuation state restored from localStorage, can resume

### Ledger Disconnect Simulation

**Hardware failure recovery**:
1. Start signing transaction
2. Mock transport disconnect event
3. Mock reconnection
4. Assert: UI shows retry option, no double-spend on successful retry

## Pact Response Decode Testing

**Critical false-positive prevention** [from userMemory]:
```typescript
// Mock chainweb returns Pact JSON types
mockAPI.get('/local', { int: 5 });
mockAPI.get('/local', { decimal: "5.0" });

// Test decode.ts unwrapping
expect(unwrapPactInt({ int: 5 })).toBe(5);
expect(unwrapPactDecimal({ decimal: "5.0" })).toBe(5.0);

// Assert raw comparison would fail (false positive source)
expect({ int: 5 } === 5).toBe(false); // This is the bug pattern
```

## Network ID Tamper Test

**Environment downgrade attack**:
1. Build with `VITE_NETWORK=mainnet01`
2. Runtime attempt: `localStorage.setItem('NETWORK_OVERRIDE', 'testnet06')`  
3. Assert: Either refused with error OR confirmation dialog required
4. Never silent downgrade from mainnet to testnet

## Accessibility & Performance

**Automated audits**:
- axe-core accessibility scan on every page
- Lighthouse CI performance budgets (LCP ≤ 2.5s)
- Color contrast verification (WCAG 2.1 AA)

**Visual regression testing**:
- Playwright screenshot diffs for signing UI (tamper-risk zone)
- Before/after comparison on any UI changes

## Dual-Scope Testing Mandate

[Per guardian-pr-review-testing-protocol userMemory]:

**Isolated scope**: Test ONLY new/changed components with focused unit tests + targeted E2E
**Regression scope**: Full test suite across all three origins after ANY change

**Gate 2 requirement**: Both scopes must pass before merge approval.

## Cross-Origin Isolation Verification

**Three-origin separation test**:
1. Deploy all three origins to preview URLs
2. Verify CSP headers differ correctly (admin stricter than stakeholder)
3. Verify admin bundle NOT accessible from stakeholder origin  
4. Verify CORS restrictions enforced between origins

## Performance Budget Enforcement

**Lighthouse CI thresholds** (fail CI if exceeded):
- **Performance score**: ≥ 90
- **LCP**: ≤ 2.5s
- **TTI**: ≤ 3.5s  
- **Bundle size**: stakeholder ≤ 1MB gzipped, admin ≤ 800KB gzipped

**Multi-chain query timing**: 20-chain balance load ≤ 15s with progress indicators