---
name: web-hosting
description: "Hosting + DNS + CI/CD for pact-community.org — Cloudflare Pages + Cloudflare Access + Cloudflare DNS, per-PR previews, three-origin deploy pipeline, HSTS preload, CAA, DNSSEC."
---
# Web Hosting

## Platform Architecture

**Cloudflare Pages** for all three origins:
- pact-community.org (marketing site)
- app.pact-community.org (stakeholder SPA)  
- admin.pact-community.org (admin SPA)

**Cloudflare DNS** with DNSSEC enabled.
**Cloudflare Access** on admin origin only (IP allowlist + SSO).

## DNS Configuration

**Primary domain**: pact-community.org
**Subdomains**: app.pact-community.org, admin.pact-community.org
**Reserved**: api.pact-community.org (future backend)

**Security records**:
- DNSSEC enabled on zone
- CAA record pinning to single certificate authority
- HSTS preload submitted to Chrome preload list

## Defensive Domain Strategy

**Register variants**: 
- pactcommunity.com, pactcommunity.xyz, pactcommunity.app
- pact-community.io, pactcommunity.co
- Punycode at-risk: pactcommunitý.io, раctcommunity.io

**Monitor Certificate Transparency** via crt.sh feed for unauthorized certificates.

## CI/CD Pipeline

**Separate workflows** per origin with path filtering:
- `.github/workflows/deploy-marketing.yml` (trigger: `web-examples/apps/marketing/**`)
- `.github/workflows/deploy-stakeholder.yml` (trigger: `web-examples/apps/stakeholder-app/**`)
- `.github/workflows/deploy-admin.yml` (trigger: `web-examples/apps/admin-app/**`)

**Build order**:
1. Core packages (`@pact-community/ui`, `@pact-community/pact-bindings`, `@pact-community/web-config`)
2. App-specific builds
3. Deploy to Cloudflare Pages

## Preview Deployments

**Per-PR previews** via Cloudflare Pages automatic preview URLs:
- Format: `{pr-id}.{project-name}.pages.dev`
- Automatic HTTPS certificates
- Same build process as production

## Environment Strategy

**Network selection by hostname + localStorage override**:
- localhost → devnet (port 8081)
- staging-app.pact-community.org → testnet06
- app.pact-community.org → mainnet01

**Override** (hidden in production): localStorage key `NETWORK_OVERRIDE` with values `devnet|testnet|mainnet`.

## Security Headers & Secrets

**Secrets via Cloudflare Pages environment variables only**:
- No NEXT_PUBLIC_/VITE_ prefixed secrets (CI regex scan enforces)
- Sentry DSN, Plausible domain (marketing only)

**Source maps**: uploaded private-only to Sentry, not served publicly.

## Deployment Gates

**Production deploy gated on**:
- Tester GO decision (all E2E tests pass)
- Security APPROVE (no critical findings)
- DevOps final pre-flight checks

**Rollback**: Cloudflare Pages instant rollback to previous deployment via dashboard.

## Build Artifacts

**SBOM generation** (CycloneDX format) per release for supply chain auditing.
**Performance budgets** enforced via Lighthouse CI in pipeline.
**Bundle analysis** with size increase alerts on PR comments.

## Health Monitoring

**Uptime monitoring**: Cloudflare built-in + external pingdom
**Error tracking**: Sentry with sanitized context (no addresses in error tags)  
**Analytics**: Plausible on marketing origin only (privacy-first)

## Access Control

**Admin origin** (admin.pact-community.org):
- Cloudflare Access with IP allowlist for core team
- Optional SSO integration (GitHub/Google) for contractors
- Separate CSP policy (stricter than stakeholder app)

**Stakeholder origin** (app.pact-community.org):
- Public access
- Rate limiting via Cloudflare
- Bot protection enabled

## Backup & Recovery

**Git source**: Primary source of truth
**Deploy history**: Cloudflare Pages maintains deployment history
**DNS backup**: Zone file export scheduled weekly
**Recovery time objective**: < 15 minutes for rollback, < 2 hours for full rebuild