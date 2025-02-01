;; TokenPulse - Token Analytics Contract

;; Data Variables
(define-map token-stats
    { token-id: principal }
    {
        total-transfers: uint,
        unique-holders: uint,
        total-volume: uint,
        largest-transfer: uint,
        average-transfer: uint,
        price-data: {
            current-price: uint,
            all-time-high: uint,
            all-time-low: uint
        }
    }
)

(define-map holder-balances
    { token-id: principal, holder: principal }
    { 
        balance: uint,
        last-transfer: uint,
        transfer-count: uint
    }
)

(define-map historical-data
    { token-id: principal, timestamp: uint }
    {
        daily-volume: uint,
        active-holders: uint,
        price: uint,
        volatility: uint
    }
)

(define-map token-metrics
    { token-id: principal }
    {
        velocity: uint,
        concentration-index: uint,
        turnover-ratio: uint
    }
)

;; Error Constants  
(define-constant ERR-INVALID-TOKEN (err u100))
(define-constant ERR-UNAUTHORIZED (err u101))
(define-constant ERR-INVALID-PRICE (err u102))

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
        (try! (calculate-metrics token-id))
        (ok true)
    )
)

(define-public (update-price-data
    (token-id principal)
    (price uint))
    (let ((current-stats (unwrap-panic (get-token-stats token-id))))
        (map-set token-stats
            {token-id: token-id}
            (merge current-stats {
                price-data: {
                    current-price: price,
                    all-time-high: (if (> price (get all-time-high (get price-data current-stats)))
                        price
                        (get all-time-high (get price-data current-stats))),
                    all-time-low: (if (< price (get all-time-low (get price-data current-stats)))
                        price
                        (get all-time-low (get price-data current-stats)))
                }
            })
        )
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
                        (get largest-transfer stats-data)),
                    average-transfer: (/ (+ (get total-volume stats-data) amount)
                                       (+ (get total-transfers stats-data) u1)),
                    price-data: (get price-data stats-data)
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
                    largest-transfer: amount,
                    average-transfer: amount,
                    price-data: {
                        current-price: u0,
                        all-time-high: u0,
                        all-time-low: u0
                    }
                }
            )
            (ok true)
        )
    )
)

(define-private (calculate-metrics (token-id principal))
    (let ((stats (unwrap-panic (get-token-stats token-id))))
        (map-set token-metrics
            {token-id: token-id}
            {
                velocity: (/ (get total-volume stats) (get unique-holders stats)),
                concentration-index: (calculate-concentration token-id),
                turnover-ratio: (/ (get total-volume stats) 
                                 (get current-price (get price-data stats)))
            }
        )
        (ok true)
    )
)

(define-private (calculate-concentration (token-id principal))
    ;; Placeholder for Gini coefficient calculation
    u0
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

(define-read-only (get-token-metrics (token-id principal))
    (ok (map-get? token-metrics {token-id: token-id}))
)
