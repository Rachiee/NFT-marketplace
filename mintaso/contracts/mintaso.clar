;; Define SIP-009 NFT Trait
(define-trait nft-trait
    (
        ;; Transfer token to a specified principal
        (transfer (uint principal principal) (response bool uint))

        ;; Get the owner of the specified token ID
        (get-owner (uint) (response (optional principal) uint))

        ;; Get the last token ID
        (get-last-token-id () (response uint uint))

        ;; Get the token URI
        (get-token-uri (uint) (response (optional (string-utf8 256)) uint))
    )
)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-not-found (err u102))
(define-constant err-listing-not-found (err u103))
(define-constant err-insufficient-funds (err u104))
(define-constant err-invalid-price (err u105))
(define-constant err-marketplace-paused (err u106))

;; Data Variables
(define-data-var last-token-id uint u0)
(define-data-var marketplace-paused bool false)
(define-data-var marketplace-fee uint u250) ;; 2.5% fee (basis points)

;; Define the NFT
(define-non-fungible-token advanced-nft uint)

;; Data Maps
(define-map token-metadata 
    uint 
    {
        owner: principal,
        metadata-url: (string-utf8 256),
        creator: principal
    }
)

(define-map token-listings 
    uint 
    {
        price: uint,
        seller: principal,
        expiry: uint
    }
)

;; Private Functions
(define-private (is-owner (token-id uint))
    (match (map-get? token-metadata token-id)
        token-info (is-eq tx-sender (get owner token-info))
        false
    )    
)

(define-private (transfer-token (token-id uint) (sender principal) (recipient principal))
    (let (
        (token-data (map-get? token-metadata token-id))
    )
        (asserts! (is-some token-data) err-token-not-found)
        (try! (nft-transfer? advanced-nft token-id sender recipient))
        (map-set token-metadata token-id 
            (merge (unwrap-panic token-data)
                   {owner: recipient}))
        (ok true)
    )
)

(define-private (calculate-fee (price uint))
    (/ (* price (var-get marketplace-fee)) u10000)
)

;; Public Functions

;; SIP009: Transfer token
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (not (var-get marketplace-paused)) err-marketplace-paused)
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (asserts! (is-owner token-id) err-not-token-owner)
        ;; Ensure the recipient is not the contract owner (optional safety check)
        (asserts! (not (is-eq recipient contract-owner)) (err u999)) ;; Custom error for invalid recipient
        (transfer-token token-id sender recipient)
    )
)

;; NFT Core Functions
(define-public (mint (metadata-url (string-utf8 256)))
    (let
        ((token-id (+ (var-get last-token-id) u1)))
        (asserts! (not (var-get marketplace-paused)) err-marketplace-paused)
        ;; Ensure metadata-url is not empty
        (asserts! (> (len metadata-url) u0) (err u998)) ;; Add custom error for empty metadata-url
        (try! (nft-mint? advanced-nft token-id tx-sender))
        (map-set token-metadata token-id 
            {
                owner: tx-sender,
                metadata-url: metadata-url,
                creator: tx-sender
            })
        (var-set last-token-id token-id)
        (ok token-id))
)

;; Marketplace Functions
(define-public (list-token (token-id uint) (price uint) (expiry uint))
    (begin
        (asserts! (not (var-get marketplace-paused)) err-marketplace-paused)
        (asserts! (> price u0) err-invalid-price)
        (asserts! (is-owner token-id) err-not-token-owner)
        ;; Ensure expiry is a future block height
        (asserts! (> expiry u0) (err u997)) ;; Add custom error for invalid expiry
        (map-set token-listings token-id 
            {
                price: price,
                seller: tx-sender,
                expiry: (+ block-height expiry)
            })
        (ok true))
)

(define-public (unlist-token (token-id uint))
    (begin
        (asserts! (not (var-get marketplace-paused)) err-marketplace-paused)
        (asserts! (is-owner token-id) err-not-token-owner)
        (map-delete token-listings token-id)
        (ok true))
)

(define-public (buy-token (token-id uint))
    (let
        (
            (listing (unwrap! (map-get? token-listings token-id) err-listing-not-found))
            (price (get price listing))
            (seller (get seller listing))
            (expiry (get expiry listing))
        )
        (asserts! (not (var-get marketplace-paused)) err-marketplace-paused)
        (asserts! (<= block-height expiry) err-listing-not-found)
        (asserts! (>= (stx-get-balance tx-sender) price) err-insufficient-funds)
        (let
            (
                (fee (calculate-fee price))
                (seller-amount (- price fee))
            )
            (try! (stx-transfer? seller-amount tx-sender seller))
            (try! (stx-transfer? fee tx-sender contract-owner))
            (try! (transfer-token token-id seller tx-sender))
            (map-delete token-listings token-id)
            (ok true)))
)

;; Read-only Functions
(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id)
)

(define-read-only (get-token-listing (token-id uint))
    (map-get? token-listings token-id)
)

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
    (match (map-get? token-metadata token-id)
        token-data (ok (some (get owner token-data)))
        (ok none)
    )
)

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

;; SIP009: Get the token URI
(define-read-only (get-token-uri (token-id uint))
    (match (map-get? token-metadata token-id)
        token-data (ok (some (get metadata-url token-data)))
        (ok none)
    )
)

;; Admin Functions
(define-public (set-marketplace-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (<= new-fee u1000) err-invalid-price) ;; Max 10% fee
        (var-set marketplace-fee new-fee)
        (ok true))
)

(define-public (toggle-marketplace-pause)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set marketplace-paused (not (var-get marketplace-paused)))
        (ok true))
)

(define-public (update-expiry (token-id uint) (new-expiry uint))
    (let
        ((listing (unwrap! (map-get? token-listings token-id) err-listing-not-found)))
        (asserts! (is-eq tx-sender (get seller listing)) err-not-token-owner)
        (map-set token-listings token-id 
            (merge listing {expiry: (+ block-height new-expiry)}))
        (ok true))
)