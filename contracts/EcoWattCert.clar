;; EnergyProduction - Energy Production Certification Contract
;; This contract works alongside WattConnect to verify and certify energy production

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u200))
(define-constant err-not-certified (err u201))
(define-constant err-already-certified (err u202))
(define-constant err-invalid-certifier (err u203))
(define-constant err-invalid-amount (err u204))
(define-constant err-not-authorized (err u205))
(define-constant err-invalid-fee (err u206))
(define-constant err-invalid-minimum (err u207))
(define-constant err-invalid-string (err u208))
(define-constant err-invalid-reason (err u209))

;; Define data variables
(define-data-var certification-fee uint u1000) ;; Fee in microstacks for certification
(define-data-var minimum-production uint u100) ;; Minimum energy production required (in kWh)
(define-data-var max-fee uint u1000000) ;; Maximum allowed certification fee
(define-data-var max-production uint u1000000) ;; Maximum allowed production amount

;; Define data maps
(define-map certified-producers principal bool)
(define-map authorized-certifiers principal bool)
(define-map producer-energy-data
    principal
    {
        total-production: uint,
        last-certification-date: uint,
        energy-source: (string-ascii 20),
        certification-status: bool,
        revocation-reason: (optional (string-ascii 50)),
        revocation-date: (optional uint),
        revoked-by: (optional principal)
    })

;; Private functions
(define-private (is-authorized-certifier (certifier principal))
    (default-to false (map-get? authorized-certifiers certifier)))

(define-private (validate-string (input (string-ascii 20)))
    (let 
        ((length (len input)))
        (and (> length u0) (<= length u20))))

(define-private (validate-revocation-reason (reason (string-ascii 50)))
    (let 
        ((length (len reason)))
        (and (> length u0) (<= length u50))))

(define-private (can-revoke-certification (caller principal))
    (or 
        (is-eq caller contract-owner)
        (is-authorized-certifier caller)))

;; Public functions

;; Add a new certifier (only contract owner)
(define-public (add-certifier (certifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        ;; Check if certifier is not the contract owner and not already authorized
        (asserts! (and 
            (not (is-eq certifier contract-owner))
            (not (default-to false (map-get? authorized-certifiers certifier)))
        ) err-invalid-certifier)
        (map-set authorized-certifiers certifier true)
        (ok true)))


;; Certify a producer (only authorized certifiers)
(define-public (certify-producer (producer principal))
    (let (
        (producer-data (default-to 
            {
                total-production: u0,
                last-certification-date: u0,
                energy-source: "",
                certification-status: false,
                revocation-reason: none,
                revocation-date: none,
                revoked-by: none
            }
            (map-get? producer-energy-data producer)))
    )
        ;; Validate certifier authorization
        (asserts! (is-authorized-certifier tx-sender) err-invalid-certifier)
        ;; Check if not already certified
        (asserts! (not (get certification-status producer-data)) err-already-certified)
        ;; Check if producer has valid data
        (asserts! (> (get total-production producer-data) u0) err-invalid-amount)

        ;; Update producer data with certification
        (map-set producer-energy-data producer
            {
                total-production: (get total-production producer-data),
                last-certification-date: block-height,
                energy-source: (get energy-source producer-data),
                certification-status: true,
                revocation-reason: none,
                revocation-date: none,
                revoked-by: none
            })
        (map-set certified-producers producer true)
        (ok true)))
