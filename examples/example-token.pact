; example-token.pact — canonical Pact 5 / KDA-CE example module for pact-kit.
;
; Intentionally minimal: NOT a fungible-v2 implementation (no interface, no
; cross-chain). It exists to demonstrate, in one place, the conventions the
; kit enforces:
;   - keyset governance behind a GOVERNANCE defcap
;   - managed capability with a manager function (linear TRANSFER allowance)
;   - capability layering: TRANSFER composes DEBIT (guard-enforced) + CREDIT
;   - @event capability (MINT) and @managed auto-emission (TRANSFER)
;   - principal-account discipline (is-principal + validate-principal)
;   - trust-boundary validation (amount sign, precision, account shape)
;   - table reads let-bound BEFORE enforce (required on the KDA-CE node —
;     see instructions/pact-traps.md, "Read-only context")
;
; Test suite: example-token.repl (run: pact examples/example-token.repl)

(namespace "free")

(module example-token GOVERNANCE
  @doc "Minimal example token demonstrating pact-kit conventions."

  ; --------------------------------------------------------------------------
  ; Constants
  ; --------------------------------------------------------------------------
  (defconst PRECISION:integer 12)
  (defconst MIN_ACCOUNT_LENGTH:integer 3)
  (defconst MAX_ACCOUNT_LENGTH:integer 256)

  ; --------------------------------------------------------------------------
  ; Schema / tables
  ; --------------------------------------------------------------------------
  (defschema account-schema
    balance:decimal
    guard:guard)

  (deftable accounts:{account-schema})

  ; --------------------------------------------------------------------------
  ; Capabilities
  ; --------------------------------------------------------------------------
  (defcap GOVERNANCE ()
    (enforce-guard (keyset-ref-guard "free.example-admin")))

  (defcap DEBIT (account:string)
    @doc "Row-guard enforcement for debits. Only composed, never public."
    (with-read accounts account { "guard" := g }
      (enforce-guard g)))

  (defcap CREDIT (account:string)
    @doc "Credit permission token. Only composed under TRANSFER or MINT."
    (enforce (!= account "") "Invalid receiver"))

  (defcap TRANSFER:bool (sender:string receiver:string amount:decimal)
    @doc "Managed transfer allowance: sign for the total, spend it in parts."
    @managed amount TRANSFER-mgr
    (enforce (!= sender receiver) "Sender and receiver must differ")
    (enforce-valid-amount amount)
    (compose-capability (DEBIT sender))
    (compose-capability (CREDIT receiver)))

  (defun TRANSFER-mgr:decimal (managed:decimal requested:decimal)
    (let ((remaining (- managed requested)))
      (enforce (>= remaining 0.0)
               (format "TRANSFER exceeded: {} requested, {} available"
                       [requested, managed]))
      remaining))

  (defcap MINT:bool (receiver:string amount:decimal)
    @doc "Admin-only supply creation. @event => auditable on-chain."
    @event
    (compose-capability (GOVERNANCE))
    (compose-capability (CREDIT receiver)))

  ; --------------------------------------------------------------------------
  ; Validation (trust boundary — every external input passes through these)
  ; --------------------------------------------------------------------------
  (defun enforce-valid-amount:bool (amount:decimal)
    (enforce (> amount 0.0) "Amount must be positive")
    (enforce (= (floor amount PRECISION) amount)
             (format "Amount {} violates precision {}" [amount, PRECISION])))

  (defun enforce-valid-account:bool (account:string)
    (let ((len (length account)))
      (enforce (and (>= len MIN_ACCOUNT_LENGTH) (<= len MAX_ACCOUNT_LENGTH))
               (format "Account length out of range [{}-{}]"
                       [MIN_ACCOUNT_LENGTH, MAX_ACCOUNT_LENGTH])))
    (enforce (is-charset CHARSET_LATIN1 account)
             "Account does not conform to charset LATIN1"))

  ; --------------------------------------------------------------------------
  ; Public functions
  ; --------------------------------------------------------------------------
  (defun create-account:string (account:string guard:guard)
    @doc "Principal accounts only: the account string must be derived from \
    \ the guard (coin's enforce-reserved discipline, strict variant)."
    (enforce-valid-account account)
    (enforce (is-principal account) "Only principal accounts can be created")
    (enforce (validate-principal guard account)
             "Reserved principal violation: account does not match guard")
    (insert accounts account { "balance": 0.0, "guard": guard })
    (format "Account {} created" [account]))

  (defun get-balance:decimal (account:string)
    (with-read accounts account { "balance" := balance }
      balance))

  (defun mint:string (receiver:string amount:decimal)
    @doc "Create supply. Guarded by GOVERNANCE via the MINT capability."
    (enforce-valid-amount amount)
    (with-capability (MINT receiver amount)
      (credit receiver amount))
    (format "Minted {} to {}" [amount, receiver]))

  (defun transfer:string (sender:string receiver:string amount:decimal)
    @doc "Transfer between existing accounts. Requires a TRANSFER-scoped \
    \ signature from the sender (managed allowance)."
    (with-capability (TRANSFER sender receiver amount)
      (debit sender amount)
      (credit receiver amount))
    (format "Transferred {} from {} to {}" [amount, sender, receiver]))

  ; --------------------------------------------------------------------------
  ; Internal functions — gated on composed capabilities, never public
  ; --------------------------------------------------------------------------
  (defun debit:string (account:string amount:decimal)
    (require-capability (DEBIT account))
    ; Table read is let-bound BEFORE the enforce: reads inside an enforce
    ; condition pass in the REPL but FAIL on the KDA-CE node.
    (let ((balance (get-balance account)))
      (enforce (>= balance amount)
               (format "Insufficient funds: balance {}, requested {}"
                       [balance, amount]))
      (update accounts account { "balance": (- balance amount) })))

  (defun credit:string (account:string amount:decimal)
    (require-capability (CREDIT account))
    (with-read accounts account { "balance" := balance }
      (update accounts account { "balance": (+ balance amount) })))
)

(create-table accounts)
