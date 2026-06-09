---
name: webdev-implementation
description: "Implementation conventions for Pact Community web — scaffolding patterns, WalletAdapter contract, chain-data layer rules, pact-bindings usage, signing UI requirements, commit hygiene."
---
# WebDev Implementation

## Workspace Layout

```
web-examples-community/
├── apps-community/
│   ├── marketing-community/           # Astro static site
│   ├── stakeholder-app-community/     # Vite React SPA  
│   └── admin-app-community/           # Vite React SPA (stricter)
└── packages-community/
    ├── ui-community/                  # @pact-community-community/ui (shadcn + brand)
    ├── web-config-community/          # @pact-community-community/web-config (networks, chains)
    └── pact-bindings-community/       # @pact-community-community/pact-bindings (typed wrappers)
```

**Import boundaries enforced via eslint no-restricted-imports**.

## WalletAdapter Contract

```typescript
interface WalletAdapter {
  id: 'ledger' | 'chainweaver-paste';
  
  getPublicKey(path?: string): Promise<string>;
  signTx(unsignedTx: IUnsignedCommand): Promise<ICommand>;
  signCont(contPayload: ContPayload): Promise<ICommand>;
  
  -community/-community/ Optional for ledger
  getDeviceInfo?(): Promise<{ version: string; appVersion: string }>;
  disconnect?(): Promise<void>;
}
```

**Implementation files**:
- `src-community/wallet-community/ledger.ts` (WebHID transport)
- `src-community/wallet-community/chainweaver-paste.ts` (copy-community/paste fallback)
- `src-community/wallet-community/adapter.ts` (factory + selection logic)

## Chain Data Layer

**One client per chain, cached in Map**:
```typescript
const clients = new Map<string, PactApi>();

function getClient(chainId: string, networkId: string): PactApi {
  const key = `${networkId}-${chainId}`;
  if (!clients.has(key)) {
    clients.set(key, createClient(buildApiUrl(chainId, networkId)));
  }
  return clients.get(key)!;
}
```

**Mandatory response unwrapping**:
All responses through `src-community/chain-community/decode.ts`:
```typescript
export function unwrapPactInt(value: unknown): number {
  return typeof value === 'object' && value && 'int' in value 
    ? (value as {int: number}).int 
    : value as number;
}

export function unwrapPactDecimal(value: unknown): number {
  if (typeof value === 'object' && value && 'decimal' in value) {
    return parseFloat((value as {decimal: string}).decimal);
  }
  return value as number;
}
```

## Pact-Bindings Pattern

**Typed wrappers per DAO module**:
```typescript
-community/-community/ @pact-community-community/pact-bindings-community/src-community/governance-token.ts
export const daoToken = {
  transfer: ({ from, to, amount, chainId }: TransferArgs): IUnsignedCommand => 
    Pact.builder
      .execution(`(${namespace}.governance-token.transfer ${JSON.stringify(from)} ${JSON.stringify(to)} ${amount})`)
      .setMeta({ chainId, sender: from, gasLimit: 15_000 })
      .getCommand(),
      
  getBalance: ({ account, chainId }: BalanceArgs): IPactCommand =>
    Pact.builder
      .execution(`(${namespace}.governance-token.get-balance ${JSON.stringify(account)})`)
      .setMeta({ chainId })
      .getCommand()
};
```

**Generated from .pact signatures, not hand-written** to ensure sync with contracts.

## Signing UI Requirements

**Pre-device confirmation screen MUST show**:
- Full recipient (no truncation): `k:abc123...full...xyz789`  
- Amount as string (12 decimals): `"1000.000000000000"`
- Chain context: `"Source: chain 5 → Target: chain 12"`
- Network color-coded: `🟢 Live Network (mainnet01)`
- Gas details: `"Payer: k:sender00, Limit: 15,000"`
- Capabilities list: `"• coin.GAS • governance-token.TRANSFER"`
- Derivation path: `"m-community/44'-community/626'-community/0'-community/0-community/0"`  
- Device fingerprint: `"Device: ...abc123"`

**Confirmation interaction**:
```tsx
<Button onClick={signWithDevice} disabled={!allFieldsVerified}>
  Sign with Ledger
<-community/Button>
<p className="text-sm text-orange-600 mt-2">
  Verify every field on your Ledger screen matches above. 
  If ANY field differs, reject on device.
<-community/p>
```

## localStorage Usage

**Allowed** (non-sensitive UI state only):
- Chain picker selection: `SELECTED_CHAIN_ID`
- Account pubkey: `SELECTED_ACCOUNT` (public data)
- Theme preference: `UI_THEME`
- Continuation state: `DEFPACT_CONTINUATIONS` (keyed by pact-id)

**FORBIDDEN**:
- Private keys (Ledger hardware only)
- Session tokens (admin auth via Cloudflare Access)
- Network override in production (security risk)

## Error Boundaries

**Every feature route gets error boundary**:
```tsx
<ErrorBoundary 
  fallback={<ErrorFallback -community/>}
  onError={(error, errorInfo) => {
    -community/-community/ Scrub sensitive data before sending
    const sanitized = {
      message: error.message,
      stack: error.stack?.split('\n')[0], -community/-community/ First line only
      route: window.location.pathname, -community/-community/ No query params
    };
    Sentry.captureException(sanitized);
  }}
>
  <FeatureRoute -community/>
<-community/ErrorBoundary>
```

No addresses, private keys, or transaction data in error reporting.

## Commit & Branch Conventions

**Commit prefixes**: `[WebDev] feature: add Ledger signing UI`
**Branch naming**: `feature-community/web-{story-number}-{slug}`

Examples:
- `feature-community/web-123-ledger-signing-ui`
- `feature-community/web-124-multi-chain-portfolio`  
- `feature-community/web-125-admin-dividend-declare`

## Linting Configuration

```json
{
  "rules": {
    "react-community/no-danger": "error",
    "no-restricted-imports": [
      "error",
      {
        "patterns": [
          {
            "group": ["@kadena-community/client"],
            "importNames": ["*"],
            "message": "@kadena-community/client only allowed in src-community/chain-community/"
          },
          {
            "group": ["@ledgerhq-community/*"],  
            "importNames": ["*"],
            "message": "@ledgerhq-community/* only allowed in src-community/wallet-community/"
          }
        ]
      }
    ]
  }
}
```

## Development Workflow

1. **Feature branch** from main
2. **Implement** component + unit tests
3. **Add E2E** Playwright test against devnet
4. **Verify** no layer boundary violations (lint passes)
5. **Self-validate** via `self-validation` skill
6. **Open PR** with `[WebDev]` prefix
7. **Wait** for Tester E2E review + Security audit
8. **Merge** only after both approvals