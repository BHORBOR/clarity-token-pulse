;; TokenPulse - Token Analytics Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant PRECISION u1000000) ;; 6 decimal places for calculations

;; Data Variables
(define-data-var initialized bool false)
(define-data-var last-price-update uint u0)

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
            all-time-low: uint,
            time-weighted-average: uint
        }
    }
)

;; [Previous maps remain unchanged]

;; Error Constants
(define-constant ERR-NOT-INITIALIZED (err u103))
(define-constant ERR-ALREADY-INITIALIZED (err u104))
(define-constant ERR-NOT-OWNER (err u105))
(define-constant ERR-OVERFLOW (err u106))

;; Authorization
(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT_OWNER)
)

;; Initialization
(define-public (initialize)
    (begin
        (asserts! (not (var-get initialized)) ERR-ALREADY-INITIALIZED)
        (asserts! (is-contract-owner) ERR-NOT-OWNER)
        (var-set initialized true)
        (ok true)
    )
)

;; Public Functions
(define-public (register-transfer 
    (token-id principal)
    (from principal)
    (to principal)
    (amount uint))
    (begin
        (asserts! (var-get initialized) ERR-NOT-INITIALIZED)
        (asserts! (< (+ amount u0) u340282366920938463463374607431768211455) ERR-OVERFLOW)
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
    (begin
        (asserts! (var-get initialized) ERR-NOT-INITIALIZED)
        (asserts! (> price u0) ERR-INVALID-PRICE)
        (let (
            (current-stats (unwrap-panic (get-token-stats token-id)))
            (current-time block-height)
            (time-diff (- current-time (var-get last-price-update)))
            (twap (calculate-twap 
                (get time-weighted-average (get price-data current-stats))
                price 
                time-diff)))
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
                            (get all-time-low (get price-data current-stats))),
                        time-weighted-average: twap
                    }
                })
            )
            (var-set last-price-update current-time)
            (ok true)
        )
    )
)

;; Private Functions

(define-private (calculate-twap (old-twap uint) (new-price uint) (time-diff uint))
    (if (is-eq time-diff u0)
        old-twap
        (/ (+ (* old-twap (- PRECISION u1)) (* new-price u1)) PRECISION)
    )
)

(define-private (calculate-concentration (token-id principal))
    (let ((holders-data (get-all-holders token-id)))
        ;; Proper Gini coefficient calculation
        ;; Sum of absolute differences divided by (2 * mean * n^2)
        ;; Placeholder returns u0 until full implementation
        u0
    )
)

;; [Previous functions remain unchanged]

;; Read-Only Functions
;; [Previous read-only functions remain unchanged]
