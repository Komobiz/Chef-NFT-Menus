

(define-non-fungible-token chef-menu uint)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-chef (err u101))
(define-constant err-not-token-owner (err u102))
(define-constant err-menu-not-found (err u103))
(define-constant err-already-redeemed (err u104))
(define-constant err-chef-not-found (err u105))
(define-constant err-invalid-price (err u106))
(define-constant err-mint-failed (err u107))

(define-data-var last-token-id uint u0)
(define-data-var contract-uri (optional (string-utf8 256)) none)

(define-map chefs principal {
  name: (string-utf8 64),
  restaurant: (string-utf8 64),
  verified: bool,
  total-menus: uint
})

(define-map menu-details uint {
  chef: principal,
  dish-name: (string-utf8 64),
  description: (string-utf8 256),
  price: uint,
  experience-type: (string-utf8 32),
  max-redemptions: uint,
  current-redemptions: uint,
  active: bool,
  created-at: uint
})

(define-map token-redemptions uint {
  redeemed: bool,
  redeemed-at: (optional uint),
  redeemer: (optional principal)
})

(define-map chef-earnings principal uint)

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://chef-nft-menus.com/metadata/{id}"))
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? chef-menu token-id))
)

(define-read-only (get-chef-info (chef principal))
  (map-get? chefs chef)
)

(define-read-only (get-menu-details (token-id uint))
  (map-get? menu-details token-id)
)

(define-read-only (get-redemption-status (token-id uint))
  (map-get? token-redemptions token-id)
)

(define-read-only (get-chef-earnings (chef principal))
  (default-to u0 (map-get? chef-earnings chef))
)

(define-read-only (is-chef-verified (chef principal))
  (match (map-get? chefs chef)
    chef-data (get verified chef-data)
    false
  )
)

(define-public (register-chef (name (string-utf8 64)) (restaurant (string-utf8 64)))
  (let ((chef tx-sender))
    (ok (map-set chefs chef {
      name: name,
      restaurant: restaurant,
      verified: false,
      total-menus: u0
    }))
  )
)

(define-public (verify-chef (chef principal))
  (if (is-eq tx-sender contract-owner)
    (match (map-get? chefs chef)
      chef-data 
      (ok (map-set chefs chef (merge chef-data { verified: true })))
      err-chef-not-found
    )
    err-owner-only
  )
)

(define-public (mint-menu-nft 
  (dish-name (string-utf8 64))
  (description (string-utf8 256))
  (price uint)
  (experience-type (string-utf8 32))
  (max-redemptions uint)
  (recipient principal)
)
  (let (
    (token-id (+ (var-get last-token-id) u1))
    (chef tx-sender)
  )
    (asserts! (> price u0) err-invalid-price)
    (asserts! (is-some (map-get? chefs chef)) err-not-chef)
    (asserts! (is-chef-verified chef) err-not-chef)
    
    (try! (nft-mint? chef-menu token-id recipient))
    
    (map-set menu-details token-id {
      chef: chef,
      dish-name: dish-name,
      description: description,
      price: price,
      experience-type: experience-type,
      max-redemptions: max-redemptions,
      current-redemptions: u0,
      active: true,
      created-at: stacks-block-height
    })
    
    (map-set token-redemptions token-id {
      redeemed: false,
      redeemed-at: none,
      redeemer: none
    })
    
    (match (map-get? chefs chef)
      chef-data 
      (map-set chefs chef (merge chef-data { total-menus: (+ (get total-menus chef-data) u1) }))
      false
    )
    
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (asserts! (is-eq sender (unwrap! (nft-get-owner? chef-menu token-id) err-not-token-owner)) err-not-token-owner)
    (nft-transfer? chef-menu token-id sender recipient)
  )
)

(define-public (redeem-experience (token-id uint))
  (let (
    (token-owner (unwrap! (nft-get-owner? chef-menu token-id) err-not-token-owner))
    (menu-info (unwrap! (map-get? menu-details token-id) err-menu-not-found))
    (redemption-info (unwrap! (map-get? token-redemptions token-id) err-menu-not-found))
  )
    (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
    (asserts! (not (get redeemed redemption-info)) err-already-redeemed)
    (asserts! (get active menu-info) err-menu-not-found)
    (asserts! (< (get current-redemptions menu-info) (get max-redemptions menu-info)) err-already-redeemed)
    
    (map-set token-redemptions token-id {
      redeemed: true,
      redeemed-at: (some stacks-block-height),
      redeemer: (some tx-sender)
    })
    
    (map-set menu-details token-id 
      (merge menu-info { current-redemptions: (+ (get current-redemptions menu-info) u1) })
    )
    
    (let ((chef (get chef menu-info))
          (current-earnings (get-chef-earnings chef))
          (price (get price menu-info)))
      (map-set chef-earnings chef (+ current-earnings price))
    )
    
    (ok true)
  )
)

(define-public (deactivate-menu (token-id uint))
  (let (
    (menu-info (unwrap! (map-get? menu-details token-id) err-menu-not-found))
    (chef (get chef menu-info))
  )
    (asserts! (is-eq tx-sender chef) err-not-chef)
    (asserts! (get active menu-info) err-menu-not-found)
    
    (ok (map-set menu-details token-id (merge menu-info { active: false })))
  )
)

(define-public (reactivate-menu (token-id uint))
  (let (
    (menu-info (unwrap! (map-get? menu-details token-id) err-menu-not-found))
    (chef (get chef menu-info))
  )
    (asserts! (is-eq tx-sender chef) err-not-chef)
    (asserts! (not (get active menu-info)) err-menu-not-found)
    
    (ok (map-set menu-details token-id (merge menu-info { active: true })))
  )
)

(define-public (bulk-mint-menus 
  (dish-names (list 10 (string-utf8 64)))
  (descriptions (list 10 (string-utf8 256)))
  (prices (list 10 uint))
  (experience-types (list 10 (string-utf8 32)))
  (max-redemptions-list (list 10 uint))
  (recipients (list 10 principal))
)
  (let (
    (chef tx-sender)
  )
    (asserts! (is-some (map-get? chefs chef)) err-not-chef)
    (asserts! (is-chef-verified chef) err-not-chef)
    
    (ok (map mint-single-menu 
      (zip dish-names descriptions prices experience-types max-redemptions-list recipients)
    ))
  )
)

(define-private (mint-single-menu (params { dish-name: (string-utf8 64), description: (string-utf8 256), price: uint, experience-type: (string-utf8 32), max-redemptions: uint, recipient: principal }))
  (let (
    (token-id (+ (var-get last-token-id) u1))
    (chef tx-sender)
  )
    (asserts! (> (get price params) u0) err-invalid-price)
    
    (try! (nft-mint? chef-menu token-id (get recipient params)))
    
    (map-set menu-details token-id {
      chef: chef,
      dish-name: (get dish-name params),
      description: (get description params),
      price: (get price params),
      experience-type: (get experience-type params),
      max-redemptions: (get max-redemptions params),
      current-redemptions: u0,
      active: true,
      created-at: stacks-block-height
    })
    
    (map-set token-redemptions token-id {
      redeemed: false,
      redeemed-at: none,
      redeemer: none
    })
    
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-private (zip (a (list 10 (string-utf8 64))) (b (list 10 (string-utf8 256))) (c (list 10 uint)) (d (list 10 (string-utf8 32))) (e (list 10 uint)) (f (list 10 principal)))
  (map create-params-tuple a b c d e f)
)

(define-private (create-params-tuple 
  (dish-name (string-utf8 64)) 
  (description (string-utf8 256)) 
  (price uint) 
  (experience-type (string-utf8 32)) 
  (max-redemptions uint) 
  (recipient principal)
)
  { 
    dish-name: dish-name, 
    description: description, 
    price: price, 
    experience-type: experience-type, 
    max-redemptions: max-redemptions, 
    recipient: recipient 
  }
)

(define-public (get-contract-info)
  (ok {
    total-tokens: (var-get last-token-id),
    contract-owner: contract-owner,
    contract-uri: (var-get contract-uri)
  })
)

(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (if (is-eq tx-sender contract-owner)
    (ok (var-set contract-uri new-uri))
    err-owner-only
  )
)

(define-read-only (get-menu-by-chef (chef principal))
  (let ((chef-data (unwrap! (map-get? chefs chef) err-chef-not-found)))
    (ok (get total-menus chef-data))
  )
)

(define-read-only (can-redeem (token-id uint))
  (match (map-get? menu-details token-id)
    menu-info
    (match (map-get? token-redemptions token-id)
      redemption-info
      (ok (and 
        (get active menu-info)
        (not (get redeemed redemption-info))
        (< (get current-redemptions menu-info) (get max-redemptions menu-info))
      ))
      (ok false)
    )
    (ok false)
  )
)
