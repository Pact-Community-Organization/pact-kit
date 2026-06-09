---
name: ux-writing
description: "UX copy standards for Pact Community web — signing prompt clarity, error messages, chain/network labeling, admin-vs-stakeholder tone, phishing-resistance copy."
---
# UX Writing

## Signing Prompt Standards

**Primary warning** (always visible on confirmation screen):
"Verify every field on your Ledger screen matches the screen above. If ANY field differs, reject on the device."

**Domain verification banner** (all sensitive pages):
"Verify your browser shows: smartpacts.io (or app/admin.smartpacts.io)"

No emoji anywhere in signing UI. Professional tone only.

## Error Message Formula

Structure every error as:
1. **What happened**: "Transaction failed"
2. **Why**: "Network connection lost during signing"  
3. **What to try**: "Check internet connection and retry"
4. **Contact**: "Still stuck? Email support@smartpacts.io"

Never blame the user. Never use technical jargon without definition.

## Network & Chain Labeling

**Color coding** (consistent across admin/stakeholder):
- **Devnet**: Orange background, "Development Network" 
- **Testnet**: Blue background, "Test Network"
- **Mainnet**: Green background, "Live Network"

**Chain formatting**:
- Always `chain 0` through `chain 19` (never bare numbers)
- Never 0-indexed hex representation
- In multi-chain contexts: "Source: chain 5 → Destination: chain 12"

## Amount Display Standards

- Always render as strings preserving full 12-decimal precision
- No truncation in any signing context: "100.000000000000" not "100.0"
- Thousand separators in display-only contexts: "1,000,000.0 KDA"
- Scientific notation BANNED in all user-facing text

## Address & Hash Display

- No truncation in signing UI contexts (show full address)
- Truncation acceptable in lists: "k:abc...xyz" with copy button for full
- All hashes/addresses in monospace font for scanning
- Copy-to-clipboard button on hover for all long identifiers

## Tone Guidelines

**Stakeholder app**: Plain English, jargon defined inline
- "Vote weight" → "Vote weight (tokens held during proposal)"
- "Gas fee" → "Transaction fee (paid in KDA)"
- "Cross-chain transfer" → "Send to different chain (chain 5 → chain 12)"

**Admin app**: Terse, operator-grade language acceptable
- "Declare dividend pool"
- "Emergency pause voting"
- "Override config parameter"

## Phishing Resistance Patterns

**URL verification prompts** (before sensitive actions):
"You are on smartpacts.io — verify this URL matches your bookmark"

**Domain warning** (if unusual referrer detected):
"Opened from external link. Verify URL: app.smartpacts.io"

**Bookmark encouragement**:
"Bookmark this page to avoid phishing. Always type the URL directly."

## Action Button Language

- Primary actions: "Sign with Ledger" / "Confirm Transfer" / "Cast Vote"
- Destructive: "Cancel Transaction" / "Reject Proposal"  
- Secondary: "Export Unsigned" / "Copy Address" / "View Details"

Never "OK" or "Submit". Always action-specific verbs.

## Loading & Progress States

- "Loading balances across 20 chains..." (with progress: "5 of 20 complete")
- "Confirming transaction on chain..." (not "Processing")
- "Waiting for Ledger signature..." (not "Please wait")
- "Broadcasting to network..." (final step clarity)

## Multi-Chain Context Clarity

Always specify chain context:
- "Balance on chain 5: 1,000.0 KDA"  
- "Vote submitted from chain 3"
- "Dividend available on chains: 0, 5, 12"

Never ambiguous references like "your balance" when multiple chains involved.