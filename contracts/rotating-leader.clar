;; Rotating Leadership DAO
;; Leadership token shifts to a new member every set number of blocks

;; Constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-MEMBER (err u101))
(define-constant ERR-NOT-MEMBER (err u102))
(define-constant ERR-NO-MEMBERS (err u103))
(define-constant ERR-INVALID-ROTATION (err u104))

(define-constant CONTRACT-OWNER tx-sender)
(define-constant BLOCKS-PER-ROTATION u144) ;; ~24 hours on Stacks (10min blocks)

;; Data Variables
(define-data-var current-leader principal CONTRACT-OWNER)
(define-data-var last-rotation-block uint block-height)
(define-data-var member-count uint u0)
(define-data-var rotation-index uint u0)

;; Data Maps
(define-map members principal bool)
(define-map member-list uint principal)
(define-map proposal-votes uint {votes-for: uint, votes-against: uint, executed: bool})
(define-map voter-record {proposal-id: uint, voter: principal} bool)

;; Read-only functions
(define-read-only (get-current-leader)
    (ok (var-get current-leader))
)

(define-read-only (get-blocks-until-rotation)
    (let (
        (current-block block-height)
        (last-rotation (var-get last-rotation-block))
        (blocks-elapsed (- current-block last-rotation))
    )
    (if (>= blocks-elapsed BLOCKS-PER-ROTATION)
        (ok u0)
        (ok (- BLOCKS-PER-ROTATION blocks-elapsed))
    ))
)

(define-read-only (is-member (account principal))
    (default-to false (map-get? members account))
)

(define-read-only (get-member-count)
    (ok (var-get member-count))
)

(define-read-only (is-rotation-due)
    (let (
        (blocks-elapsed (- block-height (var-get last-rotation-block)))
    )
    (>= blocks-elapsed BLOCKS-PER-ROTATION))
)

(define-read-only (get-next-leader)
    (let (
        (count (var-get member-count))
        (next-index (+ (var-get rotation-index) u1))
    )
    (if (> count u0)
        (ok (default-to CONTRACT-OWNER
            (map-get? member-list (mod next-index count))))
        ERR-NO-MEMBERS
    ))
)

;; Private functions
(define-private (is-leader (account principal))
    (is-eq account (var-get current-leader))
)

;; Public functions
(define-public (add-member (new-member principal))
    (begin
        (asserts! (is-leader tx-sender) ERR-NOT-AUTHORIZED)
        (asserts! (not (is-member new-member)) ERR-ALREADY-MEMBER)

        (let (
            (current-count (var-get member-count))
        )
        (map-set members new-member true)
        (map-set member-list current-count new-member)
        (var-set member-count (+ current-count u1))
        (ok true))
    )
)

(define-public (remove-member (member principal))
    (begin
        (asserts! (is-leader tx-sender) ERR-NOT-AUTHORIZED)
        (asserts! (is-member member) ERR-NOT-MEMBER)

        (map-set members member false)
        (ok true)
    )
)

(define-public (rotate-leadership)
    (let (
        (count (var-get member-count))
        (current-index (var-get rotation-index))
        (next-index (if (> count u0) (mod (+ current-index u1) count) u0))
        (next-leader (unwrap! (map-get? member-list next-index) ERR-NO-MEMBERS))
    )
    (begin
        (asserts! (is-rotation-due) ERR-INVALID-ROTATION)
        (asserts! (> count u0) ERR-NO-MEMBERS)

        (var-set current-leader next-leader)
        (var-set last-rotation-block block-height)
        (var-set rotation-index next-index)

        (ok {
            new-leader: next-leader,
            rotation-index: next-index,
            block-height: block-height
        })
    ))
)

(define-public (force-rotate)
    (begin
        (asserts! (is-leader tx-sender) ERR-NOT-AUTHORIZED)
        (var-set last-rotation-block (- block-height BLOCKS-PER-ROTATION))
        (rotate-leadership)
    )
)

;; Initialize contract
(map-set members CONTRACT-OWNER true)
(map-set member-list u0 CONTRACT-OWNER)
(var-set member-count u1)
(var-set rotation-index u0)
