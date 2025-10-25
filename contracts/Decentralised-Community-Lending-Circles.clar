(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-ALREADY-EXISTS (err u402))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-INVALID-AMOUNT (err u405))
(define-constant ERR-INSUFFICIENT-FUNDS (err u406))
(define-constant ERR-CIRCLE-FULL (err u407))
(define-constant ERR-ALREADY-MEMBER (err u408))
(define-constant ERR-NOT-MEMBER (err u409))
(define-constant ERR-CIRCLE-NOT-ACTIVE (err u410))
(define-constant ERR-CONTRIBUTION-EXISTS (err u411))
(define-constant ERR-ROUND-NOT-ACTIVE (err u412))
(define-constant ERR-ALREADY-RECEIVED-PAYOUT (err u413))
(define-constant ERR-INSUFFICIENT-CONTRIBUTIONS (err u414))

(define-data-var next-circle-id uint u1)
(define-data-var next-round-id uint u1)

(define-map circles
  { circle-id: uint }
  {
    creator: principal,
    name: (string-ascii 64),
    contribution-amount: uint,
    max-members: uint,
    current-members: uint,
    is-active: bool,
    created-at: uint,
    current-round: uint,
  }
)

(define-map circle-members
  {
    circle-id: uint,
    member: principal,
  }
  {
    joined-at: uint,
    has-received-payout: bool,
    total-contributed: uint,
  }
)

(define-map rounds
  { round-id: uint }
  {
    circle-id: uint,
    round-number: uint,
    recipient: (optional principal),
    total-pool: uint,
    is-complete: bool,
    started-at: uint,
  }
)

(define-map contributions
  {
    round-id: uint,
    contributor: principal,
  }
  {
    amount: uint,
    contributed-at: uint,
  }
)

(define-map member-list
  {
    circle-id: uint,
    index: uint,
  }
  principal
)

(define-read-only (get-circle (circle-id uint))
  (map-get? circles { circle-id: circle-id })
)

(define-read-only (get-circle-member
    (circle-id uint)
    (member principal)
  )
  (map-get? circle-members {
    circle-id: circle-id,
    member: member,
  })
)

(define-read-only (get-round (round-id uint))
  (map-get? rounds { round-id: round-id })
)

(define-read-only (get-contribution
    (round-id uint)
    (contributor principal)
  )
  (map-get? contributions {
    round-id: round-id,
    contributor: contributor,
  })
)

(define-read-only (get-member-at-index
    (circle-id uint)
    (index uint)
  )
  (map-get? member-list {
    circle-id: circle-id,
    index: index,
  })
)

(define-read-only (get-next-circle-id)
  (var-get next-circle-id)
)

(define-read-only (get-next-round-id)
  (var-get next-round-id)
)

(define-public (create-circle
    (name (string-ascii 64))
    (contribution-amount uint)
    (max-members uint)
  )
  (let (
      (circle-id (var-get next-circle-id))
      (current-block u0)
    )
    (asserts! (> contribution-amount u0) ERR-INVALID-AMOUNT)
    (asserts! (and (>= max-members u3) (<= max-members u20)) ERR-INVALID-AMOUNT)
    (map-set circles { circle-id: circle-id } {
      creator: tx-sender,
      name: name,
      contribution-amount: contribution-amount,
      max-members: max-members,
      current-members: u1,
      is-active: true,
      created-at: current-block,
      current-round: u0,
    })
    (map-set circle-members {
      circle-id: circle-id,
      member: tx-sender,
    } {
      joined-at: current-block,
      has-received-payout: false,
      total-contributed: u0,
    })
    (map-set member-list {
      circle-id: circle-id,
      index: u0,
    }
      tx-sender
    )
    (var-set next-circle-id (+ circle-id u1))
    (ok circle-id)
  )
)

(define-public (join-circle (circle-id uint))
  (let (
      (circle (unwrap! (get-circle circle-id) ERR-NOT-FOUND))
      (current-block u0)
      (member-info (get-circle-member circle-id tx-sender))
    )
    (asserts! (get is-active circle) ERR-CIRCLE-NOT-ACTIVE)
    (asserts! (is-none member-info) ERR-ALREADY-MEMBER)
    (asserts! (< (get current-members circle) (get max-members circle))
      ERR-CIRCLE-FULL
    )
    (map-set circle-members {
      circle-id: circle-id,
      member: tx-sender,
    } {
      joined-at: current-block,
      has-received-payout: false,
      total-contributed: u0,
    })
    (map-set member-list {
      circle-id: circle-id,
      index: (get current-members circle),
    }
      tx-sender
    )
    (map-set circles { circle-id: circle-id }
      (merge circle { current-members: (+ (get current-members circle) u1) })
    )
    (ok true)
  )
)

(define-public (start-new-round (circle-id uint))
  (let (
      (circle (unwrap! (get-circle circle-id) ERR-NOT-FOUND))
      (round-id (var-get next-round-id))
      (current-block u0)
      (new-round-number (+ (get current-round circle) u1))
    )
    (asserts! (get is-active circle) ERR-CIRCLE-NOT-ACTIVE)
    (asserts! (is-eq (get creator circle) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (<= new-round-number (get current-members circle))
      ERR-INVALID-AMOUNT
    )
    (map-set rounds { round-id: round-id } {
      circle-id: circle-id,
      round-number: new-round-number,
      recipient: none,
      total-pool: u0,
      is-complete: false,
      started-at: current-block,
    })
    (map-set circles { circle-id: circle-id }
      (merge circle { current-round: new-round-number })
    )
    (var-set next-round-id (+ round-id u1))
    (ok round-id)
  )
)

(define-public (contribute-to-round (round-id uint))
  (let (
      (round (unwrap! (get-round round-id) ERR-NOT-FOUND))
      (circle (unwrap! (get-circle (get circle-id round)) ERR-NOT-FOUND))
      (member-info (unwrap! (get-circle-member (get circle-id round) tx-sender) ERR-NOT-MEMBER))
      (existing-contribution (get-contribution round-id tx-sender))
      (current-block u0)
      (contribution-amount (get contribution-amount circle))
    )
    (asserts! (get is-active circle) ERR-CIRCLE-NOT-ACTIVE)
    (asserts! (not (get is-complete round)) ERR-ROUND-NOT-ACTIVE)
    (asserts! (is-none existing-contribution) ERR-CONTRIBUTION-EXISTS)
    (try! (stx-transfer? contribution-amount tx-sender (as-contract tx-sender)))
    (map-set contributions {
      round-id: round-id,
      contributor: tx-sender,
    } {
      amount: contribution-amount,
      contributed-at: current-block,
    })
    (map-set rounds { round-id: round-id }
      (merge round { total-pool: (+ (get total-pool round) contribution-amount) })
    )
    (map-set circle-members {
      circle-id: (get circle-id round),
      member: tx-sender,
    }
      (merge member-info { total-contributed: (+ (get total-contributed member-info) contribution-amount) })
    )
    (ok true)
  )
)

(define-public (select-recipient
    (round-id uint)
    (recipient principal)
  )
  (let (
      (round (unwrap! (get-round round-id) ERR-NOT-FOUND))
      (circle (unwrap! (get-circle (get circle-id round)) ERR-NOT-FOUND))
      (recipient-info (unwrap! (get-circle-member (get circle-id round) recipient) ERR-NOT-MEMBER))
    )
    (asserts! (is-eq (get creator circle) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (get is-active circle) ERR-CIRCLE-NOT-ACTIVE)
    (asserts! (not (get is-complete round)) ERR-ROUND-NOT-ACTIVE)
    (asserts! (not (get has-received-payout recipient-info))
      ERR-ALREADY-RECEIVED-PAYOUT
    )
    (asserts!
      (>= (get total-pool round)
        (* (get contribution-amount circle) (get current-members circle))
      )
      ERR-INSUFFICIENT-CONTRIBUTIONS
    )
    (map-set rounds { round-id: round-id }
      (merge round { recipient: (some recipient) })
    )
    (ok true)
  )
)

(define-public (distribute-payout (round-id uint))
  (let (
      (round (unwrap! (get-round round-id) ERR-NOT-FOUND))
      (circle (unwrap! (get-circle (get circle-id round)) ERR-NOT-FOUND))
      (recipient (unwrap! (get recipient round) ERR-NOT-FOUND))
      (recipient-info (unwrap! (get-circle-member (get circle-id round) recipient) ERR-NOT-MEMBER))
      (payout-amount (get total-pool round))
    )
    (asserts! (is-eq (get creator circle) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (get is-active circle) ERR-CIRCLE-NOT-ACTIVE)
    (asserts! (not (get is-complete round)) ERR-ROUND-NOT-ACTIVE)
    (asserts! (not (get has-received-payout recipient-info))
      ERR-ALREADY-RECEIVED-PAYOUT
    )
    (try! (as-contract (stx-transfer? payout-amount tx-sender recipient)))
    (map-set rounds { round-id: round-id } (merge round { is-complete: true }))
    (map-set circle-members {
      circle-id: (get circle-id round),
      member: recipient,
    }
      (merge recipient-info { has-received-payout: true })
    )
    (ok payout-amount)
  )
)

(define-public (close-circle (circle-id uint))
  (let ((circle (unwrap! (get-circle circle-id) ERR-NOT-FOUND)))
    (asserts! (is-eq (get creator circle) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (get is-active circle) ERR-CIRCLE-NOT-ACTIVE)
    (map-set circles { circle-id: circle-id } (merge circle { is-active: false }))
    (ok true)
  )
)
