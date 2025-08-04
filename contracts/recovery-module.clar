;; Keynest Recovery Module
;; Clarity v2
;; Social recovery using guardian consensus

(define-constant ERR-NOT-OWNER u100)
(define-constant ERR-NOT-GUARDIAN u101)
(define-constant ERR-ALREADY-RECOVERING u102)
(define-constant ERR-NOT-RECOVERING u103)
(define-constant ERR-ALREADY-VOTED u104)
(define-constant ERR-INSUFFICIENT-VOTES u105)
(define-constant ERR-INVALID-THRESHOLD u106)
(define-constant ERR-NO-GUARDIANS u107)

(define-trait IWalletOwner
  (
    (on-recovery (new-owner principal) (response bool uint))
  )
)

(define-map guardians (principal) (list 10 principal)) ;; wallet-owner => guardians list
(define-map guardian-threshold (principal) uint) ;; wallet-owner => min vote threshold
(define-map recovery-request (principal) (tuple (new-owner principal) (votes (list 10 principal)))) ;; wallet-owner => recovery vote state

;; Ensure caller is owner of wallet
(define-private (is-owner (wallet principal))
  (is-eq tx-sender wallet)
)

;; Ensure caller is guardian for wallet
(define-private (is-guardian (wallet principal) (caller principal))
  (match (map-get? guardians wallet)
    some (g-list)
      (ok (contains? g-list caller))
    none (err ERR-NO-GUARDIANS)
  )
)

;; Get current guardian list
(define-read-only (get-guardians (wallet principal))
  (ok (default-to (list) (map-get? guardians wallet)))
)

;; Get recovery threshold
(define-read-only (get-threshold (wallet principal))
  (ok (default-to u0 (map-get? guardian-threshold wallet)))
)

;; Set guardians and threshold
(define-public (set-guardians (wallet principal) (g-list (list 10 principal)) (threshold uint))
  (begin
    (asserts! (is-owner wallet) (err ERR-NOT-OWNER))
    (asserts! (> threshold u0) (err ERR-INVALID-THRESHOLD))
    (asserts! (<= threshold (len g-list)) (err ERR-INVALID-THRESHOLD))
    (map-set guardians wallet g-list)
    (map-set guardian-threshold wallet threshold)
    (ok true)
  )
)

;; Begin a new recovery attempt
(define-public (start-recovery (wallet principal) (new-owner principal))
  (begin
    (try! (is-guardian wallet tx-sender))
    (asserts! (is-none (map-get? recovery-request wallet)) (err ERR-ALREADY-RECOVERING))
    (map-set recovery-request wallet { new-owner: new-owner, votes: (list tx-sender) })
    (ok true)
  )
)

;; Vote to recover wallet to a new owner
(define-public (vote-recovery (wallet principal))
  (let (
    (guardian-check (try! (is-guardian wallet tx-sender)))
    (req (unwrap! (map-get? recovery-request wallet) (err ERR-NOT-RECOVERING)))
    (existing-votes (get votes req))
    (new-vote-list (if (contains? existing-votes tx-sender)
      (err ERR-ALREADY-VOTED)
      (ok (append existing-votes (list tx-sender)))
    ))
  )
    (map-set recovery-request wallet {
      new-owner: (get new-owner req),
      votes: (unwrap! new-vote-list (err ERR-ALREADY-VOTED))
    })
    (ok true)
  )
)

;; Finalize the recovery once threshold is met
(define-public (finalize-recovery (wallet principal))
  (let (
    (req (unwrap! (map-get? recovery-request wallet) (err ERR-NOT-RECOVERING)))
    (votes (get votes req))
    (threshold (unwrap! (map-get? guardian-threshold wallet) (err ERR-INVALID-THRESHOLD)))
  )
    (asserts! (>= (len votes) threshold) (err ERR-INSUFFICIENT-VOTES))
    (begin
      (map-delete recovery-request wallet)
      (contract-call? wallet on-recovery (get new-owner req))
    )
  )
)

;; Cancel an in-progress recovery (owner only)
(define-public (cancel-recovery (wallet principal))
  (begin
    (asserts! (is-owner wallet) (err ERR-NOT-OWNER))
    (asserts! (is-some (map-get? recovery-request wallet)) (err ERR-NOT-RECOVERING))
    (map-delete recovery-request wallet)
    (ok true)
  )
)

;; Read-only: check recovery status
(define-read-only (get-recovery-status (wallet principal))
  (ok (map-get? recovery-request wallet))
)
