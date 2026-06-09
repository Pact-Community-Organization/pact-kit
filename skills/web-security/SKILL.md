---
name: web-security
description: "Web security baseline for Pact Community — STRIDE model, strict CSP, WebHID origin pinning, Ledger signing UI rules, Chainweaver postMessage hardening, dep hygiene, pre-launch checklist."
---
# Web Security

## STRIDE Critical Items

**[CRITICAL] S-1**: Lookalike domain attacks → defensive registration, CT monitoring
**[CRITICAL] T-1**: Transaction tampering between build and device → pre-device confirmation mandatory
**[CRITICAL] T-2**: XSS execution → strict CSP, no dangerouslySetInnerHTML on user/chain content
**[CRITICAL] E-1**: Admin code leakage to stakeholder bundle → build audit enforced in CI

## Content Security Policy (Baseline)

```
default-src 'none'; 
script-src 'self'; 
style-src 'self'; 
img-src 'self' data:; 
font-src 'self'; 
connect-src 'self' https://api.chainweb-community.org https://explorer.chainweb-community.org; 
frame-src 'none'; 
frame-ancestors 'none'; 
form-action 'none'; 
base-uri 'none'; 
object-src 'none'; 
worker-src 'self'; 
manifest-src 'self'; 
upgrade-insecure-requests; 
report-uri /csp-report
```

**CSP report-only** for ≥7 days before enforcement on new policies.

## Security Headers (Complete Set)

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: no-referrer
Permissions-Policy: hid=(self) [on app/admin], hid=() [on marketing]
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Resource-Policy: same-origin
```

## Three-Origin Isolation Enforcement

**Admin bundle separation**: Admin code MUST NOT appear in stakeholder bundle.

**CI enforcement**: Build-output audit greps stakeholder dist/ for admin route names → fail on match.

**Example audit commands**:
```bash
grep -r "admin" dist/stakeholder/ && exit 1
grep -r "AdminPage\|AdminRoute" dist/stakeholder/ && exit 1
```

## Ledger Signing Security Rules

**APDU command restrictions**:
- `INS_SIGN_TRANSFER` (0x24): KDA transfers only
- `INS_SIGN` (0x22): Governance operations only  
- `INS_SIGN_HASH` (0x23): BANNED in MVP (blind signing)

**Device verification checklist** (pre-signing):
- Device version ≥ minimum required
- Kadena app version ≥ minimum required  
- WebHID filter: vendor ID 0x2c97 (Ledger)

**Pre-device confirmation screen MUST show**:
- Full recipient address (no truncation)
- Amount as string with 12-decimal precision
- Source chain + target chain explicitly
- Network ID (color-coded: devnet orange, testnet blue, mainnet green)
- Gas payer address
- Gas limit value
- TTL (time-to-live)
- All capabilities listed with parameters
- Derivation path (e.g., m/44'/626'/0'/0/0)
- Device public key fingerprint (last 8 chars)

## Chainweaver postMessage Hardening

**Origin validation**:
- Explicit `targetOrigin` (never `*`)
- Validate `event.origin` AND `event.source` against allowlist
- Reject HTTP origins (HTTPS required)

**Message validation**:
```typescript
const ChainweaverMessage = z.object({
  type: z.literal('sign-response'),
  body: z.object({
    signedCmd: z.string().min(1)
  })
});
```

**Popup controls**:
- Opened only via user gesture
- Close timeout after 5 minutes
- One popup maximum per tab

## Dependency Hygiene

**Banned dependencies**:
- crypto-js, moment, request, node-fetch
- lodash (full), jsonwebtoken  
- Generic Web3 wallet aggregators
- react-markdown without rehype-sanitize
- styled-components, Emotion (Tailwind covers styling)

**`.npmrc` enforcement**:
```
ignore-scripts=true
save-exact=true  
engine-strict=true
```

**CI lockfile verification**: `pnpm install --frozen-lockfile`

## Subdomain Takeover Protection

**Monthly scan** of all DNS records for:
- Dangling CNAME records pointing to deprovisioned services
- Expired domain registrations in CNAME chains
- Cloud service misconfigurations

## Network Security

**No third-party CDN**: All assets self-hosted via Cloudflare Pages
**No analytics** on app/admin origins (privacy + security)
**Plausible analytics** on marketing origin only (privacy-first, no tracking)

## Pre-Launch Security Checklist (Gate 3)

- [ ] CSP report-only tested ≥7 days, no violations
- [ ] All security headers verified via securityheaders.com A+ rating
- [ ] Admin bundle separation verified via CI audit  
- [ ] Ledger signing UI matches security requirements checklist
- [ ] Chainweaver integration limited to copy/paste (no postMessage in MVP)
- [ ] HTTPS enforced, HSTS preload submitted
- [ ] Source maps uploaded private-only to Sentry
- [ ] Defensive domains registered, CT monitoring active
- [ ] WebHID restricted to vendor 0x2c97 only
- [ ] All secrets via Cloudflare env vars, no frontend leakage
- [ ] SBOM generated for supply chain audit