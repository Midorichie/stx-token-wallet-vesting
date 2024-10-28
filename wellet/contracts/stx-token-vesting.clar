;; Enhanced STX Token Vesting Contract
;; Includes additional features and improvements over the initial implementation

(define-constant CONTRACT_OWNER tx-sender)

(define-data-var vesting-schedules (list 128 (tuple (start-block uint)
                                                   (duration-blocks uint)
                                                   (cliff-blocks uint)
                                                   (beneficiary principal)
                                                   (token-contract (string-ascii 128))
                                                   (total-vested-tokens uint))))
  (list))

(define-public (initialize-vesting 
                  (start-block uint)
                  (duration-blocks uint) 
                  (cliff-blocks uint)
                  (beneficiary-principal principal)
                  (token-contract (string-ascii 128)))
  (begin
    (asserts! (is-eq CONTRACT_OWNER tx-sender) err-not-contract-owner)
    (map-insert vesting-schedules (len vesting-schedules) 
                { start-block: start-block, 
                  duration-blocks: duration-blocks,
                  cliff-blocks: cliff-blocks,
                  beneficiary: beneficiary-principal,
                  token-contract: token-contract,
                  total-vested-tokens: 0 })
    (ok True)
  )
)

(define-public (claim-vested-tokens)
  (let ((vesting-index (find-vesting-index tx-sender)))
    (if (is-ok vesting-index)
      (let ((vesting-schedule (element-at vesting-schedules (unwrap-ok vesting-index))))
        (begin
          (asserts! (> (+ (get start-block vesting-schedule) (get cliff-blocks vesting-schedule)) block-height) err-tokens-not-vested)
          (let ((vested-tokens (calculate-vested-tokens (get start-block vesting-schedule) 
                                                       (get duration-blocks vesting-schedule)
                                                       (get cliff-blocks vesting-schedule) 
                                                       block-height)))
            (begin
              (map-set (get token-contract vesting-schedule) (get beneficiary vesting-schedule) (+ (get token (get token-contract vesting-schedule) (get beneficiary vesting-schedule)) vested-tokens))
              (map-set vesting-schedules (unwrap-ok vesting-index) (merge-entry vesting-schedule { total-vested-tokens: (+ (get total-vested-tokens vesting-schedule) vested-tokens) }))
              (ok vested-tokens)
            )
          )
        ))
      (err err-no-vesting-schedule)
    )
  )
)

(define-read-only (calculate-vested-tokens (start-block uint) (duration-blocks uint) (cliff-blocks uint) (current-block uint))
  (let ((total-vested (/ (* (max 0 (- current-block (+ start-block cliff-blocks))) 10000) (* duration-blocks 10000))))
    (if (< total-vested 1) 0 (/ (* 10000 total-vested) 10000))
  )
)

(define-read-only (find-vesting-index (principal))
  (map-find vesting-schedules
    (lambda (i s) 
      (is-eq (get beneficiary s) principal)
    )
  )
)