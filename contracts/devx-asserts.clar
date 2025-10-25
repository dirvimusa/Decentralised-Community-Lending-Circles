(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-INVALID-AMOUNT u101)
(define-constant ERR-INSUFFICIENT-BALANCE u102)
(define-constant ERR-INVALID-ARG u103)
(define-constant ERR-PAUSED u104)
(define-constant ERR-NOT-FOUND u105)

(define-constant NAME "devx-asserts")
(define-constant V-MAJOR u1)
(define-constant V-MINOR u0)
(define-constant V-PATCH u0)

(define-read-only (name) NAME)
(define-read-only (version) (tuple (major V-MAJOR) (minor V-MINOR) (patch V-PATCH)))

(define-read-only (error-message (code uint))
  (if (is-eq code ERR-NOT-AUTHORIZED) (some "not-authorized")
  (if (is-eq code ERR-INVALID-AMOUNT) (some "invalid-amount")
  (if (is-eq code ERR-INSUFFICIENT-BALANCE) (some "insufficient-balance")
  (if (is-eq code ERR-INVALID-ARG) (some "invalid-arg")
  (if (is-eq code ERR-PAUSED) (some "paused")
  (if (is-eq code ERR-NOT-FOUND) (some "not-found")
  none)))))))

(define-public (require-true (condition bool) (err-code uint))
  (if condition (ok true) (err err-code)))

(define-public (require-sender-is (p principal) (err-code uint))
  (if (is-eq tx-sender p) (ok true) (err err-code)))

(define-public (require-min-amount (amount uint) (min uint) (err-code uint))
  (if (>= amount min) (ok true) (err err-code)))

(define-public (require-stx-balance-at-least (who principal) (min uint) (err-code uint))
  (let ((bal (stx-get-balance who)))
    (if (>= bal min) (ok true) (err err-code))))

(define-public (checked-transfer-stx (to principal) (amount uint) (err-code uint))
  (let ((res (stx-transfer? amount tx-sender to)))
    (match res success (ok true) error (err err-code))))