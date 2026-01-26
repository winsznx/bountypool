;; BountyPool - Collaborative bounty funding
(define-constant ERR-ALREADY-CLAIMED (err u100))

(define-map bounties
    { bounty-id: uint }
    { description: (string-ascii 256), total-pool: uint, hunter: (optional principal), claimed: bool }
)

(define-map contributions { bounty-id: uint, contributor: principal } { amount: uint })
(define-data-var bounty-counter uint u0)

(define-public (create-bounty (description (string-ascii 256)))
    (let (
        (bounty-id (var-get bounty-counter))
    )
        (map-set bounties { bounty-id: bounty-id } {
            description: description,
            total-pool: u0,
            hunter: none,
            claimed: false
        })
        (var-set bounty-counter (+ bounty-id u1))
        (ok bounty-id)
    )
)

(define-public (contribute (bounty-id uint) (amount uint))
    (let (
        (bounty (unwrap! (map-get? bounties { bounty-id: bounty-id }) ERR-ALREADY-CLAIMED))
        (existing-contribution (default-to u0 (get amount (map-get? contributions { bounty-id: bounty-id, contributor: tx-sender }))))
    )
        (map-set bounties { bounty-id: bounty-id } (merge bounty { total-pool: (+ (get total-pool bounty) amount) }))
        (map-set contributions { bounty-id: bounty-id, contributor: tx-sender } { amount: (+ existing-contribution amount) })
        (ok true)
    )
)

(define-public (claim-bounty (bounty-id uint) (hunter principal))
    (let (
        (bounty (unwrap! (map-get? bounties { bounty-id: bounty-id }) ERR-ALREADY-CLAIMED))
    )
        (asserts! (not (get claimed bounty)) ERR-ALREADY-CLAIMED)
        (map-set bounties { bounty-id: bounty-id } (merge bounty { hunter: (some hunter), claimed: true }))
        (ok true)
    )
)

(define-read-only (get-bounty (bounty-id uint))
    (map-get? bounties { bounty-id: bounty-id })
)
