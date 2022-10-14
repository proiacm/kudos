
;; kudos
;; contract that allows users to give each other "kudos"

(define-constant CONTRACT_OWNER (as-contract tx-sender))
(define-constant PRICE u1000000)
(define-constant ERR_NO_KUDOS (err u100))
(define-constant ERR_CANNOT_GIVE_SELF (err u101))

(define-map kudosMap principal uint)

;; user can give kudos to another user plus a tip
(define-public (give-kudos-with-tip (recipient principal) (tip uint))
  (begin
      (try! (split-transfer recipient tip))
      (ok (add-kudos recipient))
  )
)

;; user can give kudos to another user without tip
(define-public (give-kudos (recipient principal))
  (begin 
    (asserts! (not (is-eq tx-sender recipient)) ERR_CANNOT_GIVE_SELF)
    (try! (stx-transfer? PRICE tx-sender CONTRACT_OWNER))
    (ok (add-kudos recipient))
  )
)

(define-private (add-kudos (recipient principal))
  (let 
    (
      (currentCount (default-to u0 (map-get? kudosMap recipient)))
      (updatedCount (+ currentCount u1))
    )
    (map-set kudosMap recipient updatedCount)
  )
)

(define-private (split-transfer (recipient principal) (tip uint))
  (begin
    (try! (stx-transfer? PRICE tx-sender CONTRACT_OWNER))
    (stx-transfer? tip tx-sender recipient)
  )
)

(define-read-only (get-kudos)
    (ok (unwrap! (map-get? kudosMap tx-sender) ERR_NO_KUDOS))
) 