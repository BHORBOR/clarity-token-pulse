;; TokenPulse - Token Analytics Contract

;; Data Variables
(define-map token-stats
    { token-id: principal }
    {
        total-transfers: uint,
        unique-holders: uint,
        total-volume: uint,
        largest-transfer: uint
    }
)

(define-map holder-balances
    { token-id: principal, holder: principal }
    { balance: uint }
)

(define-map historical-data
    { token-id: principal, timestamp: uint }
    {
        daily-volume: uint,
        active-holders: uint
    }
)

;; Error Constants
(define-constant ERR-INVALID-TOKEN (err u100))
(define-constant ERR-UNAUTHORIZED (err u101))

;; Public Functions

(define-public (register-transfer 
    (token-id principal)
    (from principal)
    (to principal)
    (amount uint))
    (begin
        (try! (update-token-stats token-id amount))
        (try! (update-holder-balances token-id from to amount))
        (try! (record-historical-data token-id amount))
        (ok true)
    )
)

;; Private Functions

(define-private (update-token-stats (token-id principal) (amount uint))
    (match (map-get? token-stats {token-id: token-id})
        stats-data (begin
            (map-set token-stats
                {token-id: token-id}
                {
                    total-transfers: (+ (get total-transfers stats-data) u1),
                    unique-holders: (get unique-holders stats-data),
                    total-volume: (+ (get total-volume stats-data) amount),
                    largest-transfer: (if (> amount (get largest-transfer stats-data))
                        amount
                        (get largest-transfer stats-data))
                }
            )
            (ok true)
        )
        (begin
            (map-set token-stats
                {token-id: token-id}
                {
                    total-transfers: u1,
                    unique-holders: u1,
                    total-volume: amount,
                    largest-transfer: amount
                }
            )
            (ok true)
        )
    )
)

(define-private (update-holder-balances
    (token-id principal)
    (from principal)
    (to principal)
    (amount uint))
    (begin
        (match (map-get? holder-balances {token-id: token-id, holder: from})
            from-data (map-set holder-balances
                {token-id: token-id, holder: from}
                {balance: (- (get balance from-data) amount)}
            )
            (map-set holder-balances
                {token-id: token-id, holder: from}
                {balance: u0}
            )
        )
        (match (map-get? holder-balances {token-id: token-id, holder: to})
            to-data (map-set holder-balances
                {token-id: token-id, holder: to}
                {balance: (+ (get balance to-data) amount)}
            )
            (map-set holder-balances
                {token-id: token-id, holder: to}
                {balance: amount}
            )
        )
        (ok true)
    )
)

(define-private (record-historical-data (token-id principal) (amount uint))
    (let ((current-time block-height))
        (match (map-get? historical-data {token-id: token-id, timestamp: current-time})
            existing-data (map-set historical-data
                {token-id: token-id, timestamp: current-time}
                {
                    daily-volume: (+ (get daily-volume existing-data) amount),
                    active-holders: (get active-holders existing-data)
                }
            )
            (map-set historical-data
                {token-id: token-id, timestamp: current-time}
                {
                    daily-volume: amount,
                    active-holders: u1
                }
            )
        )
        (ok true)
    )
)

;; Read-Only Functions

(define-read-only (get-token-stats (token-id principal))
    (ok (map-get? token-stats {token-id: token-id}))
)

(define-read-only (get-holder-balance (token-id principal) (holder principal))
    (ok (map-get? holder-balances {token-id: token-id, holder: holder}))
)

(define-read-only (get-historical-data (token-id principal) (timestamp uint))
    (ok (map-get? historical-data {token-id: token-id, timestamp: timestamp}))
)