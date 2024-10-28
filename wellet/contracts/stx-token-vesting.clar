;; STX Token Vesting Contract
;; This contract manages the vesting of STX tokens for a given beneficiary

(define-constant CONTRACT_OWNER tx-sender)

(define-data-var vesting-start-block (optional uint) none)
(define-data-var vesting-duration-blocks (optional uint) none)
(define-data-var vesting-cliff-blocks (optional uint) none)
(define-data-var beneficiary (optional principal) none)
(define-data-var token-contract-id (optional (string-ascii 128)) none)
(define-data-var total-vested-tokens (optional uint) none)

(define-public (initialize-vesting 
                  (start-block uint)
                  (duration-blocks uint) 
                  (cliff-blocks uint)
                  (beneficiary-principal principal)
                  (token-contract (string-ascii 128)))
  (begin
    (asserts! (is-eq CONTRACT_OWNER tx-sender) err-not-contract-owner)
    (var-set vesting-start-block start-block)
    (var-set vesting-duration-blocks duration-blocks)
    (var-set vesting-cliff-blocks cliff-blocks) 
    (var-set beneficiary beneficiary-principal)
    (var-set token-contract-id token-contract)
    (var-set total-vested-tokens 0)
    (ok True)
  )
)

(define-public (claim-vested-tokens)
  (let ((start-block (unwrap-panic (var-get vesting-start-block)))
        (duration-blocks (unwrap-panic (var-get vesting-duration-blocks)))
        (cliff-blocks (unwrap-panic (var-get vesting-cliff-blocks)))
        (beneficiary (unwrap-panic (var-get beneficiary)))
        (token-contract (unwrap-panic (var-get token-contract-id))))
    (begin
      (asserts! (is-eq tx-sender beneficiary) err-not-beneficiary)
      (asserts! (> (+ start-block cliff-blocks) block-height) err-tokens-not-vested)
      
      (let ((vested-tokens (calculate-vested-tokens start-block duration-blocks cliff-blocks block-height)))
        (begin
          (map-set (var-get token-contract-id) (var-get beneficiary) (+ (get token (var-get token-contract-id) (var-get beneficiary)) vested-tokens))
          (var-set total-vested-tokens (+ (var-get total-vested-tokens) vested-tokens))
          (ok vested-tokens)
        )
      )
    )
  )
)

(define-read-only (calculate-vested-tokens (start-block uint) (duration-blocks uint) (cliff-blocks uint) (current-block uint))
  (let ((total-vested (/ (* (max 0 (- current-block (+ start-block cliff-blocks))) 10000) (* duration-blocks 10000))))
    (if (< total-vested 1) 0 (/ (* (var-get total-vested-tokens) total-vested) 10000))
  )
)