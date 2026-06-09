---
name: code-documentation
description: "@doc annotation standards for Pact 5 modules. Function documentation, schema descriptions, capability documentation, and inline code comments."
---
# Code Documentation

## @doc Standards
```pact
(defun transfer:string
  ( sender:string
    receiver:string
    amount:decimal
  )
  @doc "Transfer AMOUNT tokens from SENDER to RECEIVER. \\
       Requires TRANSFER capability with matching parameters. \\
       Emits TRANSFER event on success."
  ...)
```

## Capability Documentation
```pact
(defcap TRANSFER (sender:string receiver:string amount:decimal)
  @doc "Managed capability for token transfers. \\
       Guards: sender's account keyset. \\
       Managed: amount decreases with each transfer."
  @managed amount TRANSFER-mgr
  ...)
```

## Schema Documentation
```pact
(defschema account-schema
  @doc "Account state tracking balance and guard"
  balance:decimal   ; Current token balance
  guard:guard       ; Account access control
)
```

## Documentation Rules
- Every public `defun` must have `@doc`
- Every `defcap` must have `@doc` explaining guard and management
- Every `defschema` must have `@doc`
- Use `\\` for line continuation in @doc strings
- Include parameter descriptions in the doc string
