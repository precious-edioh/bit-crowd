;; BitCrowd Protocol: Next-Generation Decentralized Crowdfunding Platform
;;
;; Built on Stacks blockchain, secured by Bitcoin's immutable ledger
;;
;; BitCrowd transforms the crowdfunding landscape by eliminating traditional gatekeepers
;; and empowering direct creator-backer relationships through trustless smart contracts.
;; This protocol leverages Bitcoin's security model to provide unprecedented transparency,
;; automatic fund management, and community-driven project validation.
;;
;; Key Innovation Features:
;; - Trustless escrow system with guaranteed fund security
;; - Community governance through weighted stakeholder voting
;; - Milestone-based fund release mechanisms
;; - Automatic refund processing for unsuccessful campaigns
;; - Dynamic fee structure optimized for creator success
;; - Multi-tier contribution validation system
;;
;; Technical Architecture:
;; Advanced state management with comprehensive error handling, optimized gas usage,
;; and enterprise-grade scalability for supporting thousands of concurrent campaigns
;; across diverse funding categories and project types.
;;

;; SYSTEM CONSTANTS

;; Contract Governance
(define-constant CONTRACT_OWNER tx-sender)

;; Comprehensive Error Registry
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_CAMPAIGN_NOT_FOUND (err u101))
(define-constant ERR_CAMPAIGN_ENDED (err u102))
(define-constant ERR_CAMPAIGN_ACTIVE (err u103))
(define-constant ERR_GOAL_NOT_MET (err u104))
(define-constant ERR_ALREADY_REFUNDED (err u105))
(define-constant ERR_NO_CONTRIBUTION (err u106))
(define-constant ERR_INVALID_AMOUNT (err u107))
(define-constant ERR_INVALID_PARAMETERS (err u108))
(define-constant ERR_VOTING_PERIOD_ENDED (err u109))
(define-constant ERR_ALREADY_VOTED (err u110))
(define-constant ERR_INSUFFICIENT_VOTING_POWER (err u111))
(define-constant ERR_CONTRIBUTOR_LIST_FULL (err u112))
(define-constant ERR_INVALID_STRING (err u113))

;; Campaign Lifecycle States
(define-constant STATUS_ACTIVE u1)
(define-constant STATUS_SUCCESSFUL u2)
(define-constant STATUS_FAILED u3)
(define-constant STATUS_CANCELLED u4)

;; Protocol Operational Limits
(define-constant MAX_DURATION_BLOCKS u144000)        ;; ~100 days at 10 min blocks
(define-constant MAX_VOTING_DURATION_BLOCKS u14400)  ;; ~10 days voting period
(define-constant MIN_DURATION_BLOCKS u144)           ;; ~1 day minimum duration
(define-constant MAX_CAMPAIGN_ID u1000000)           ;; System scalability limit

;; GLOBAL STATE

(define-data-var campaign-counter uint u0)
(define-data-var platform-fee-rate uint u250)  ;; 2.5% platform fee (250/10000)

;; DATA STRUCTURES

;; Primary Campaign Registry
(define-map campaigns
  { campaign-id: uint }
  {
    creator: principal,
    title: (string-ascii 64),
    description: (string-ascii 256),
    goal: uint,
    raised: uint,
    deadline-height: uint,
    created-height: uint,
    status: uint,
    voting-enabled: bool,
    voting-deadline-height: uint,
    votes-for: uint,
    votes-against: uint,
    min-contribution: uint,
  }
)

;; Contributor Investment Registry
(define-map contributions
  {
    campaign-id: uint,
    contributor: principal,
  }
  {
    amount: uint,
    refunded: bool,
    voting-power: uint,
  }
)

;; Community Governance Voting System
(define-map contributor-votes
  {
    campaign-id: uint,
    voter: principal,
  }
  {
    voted: bool,
    vote-for: bool,
  }
)

;; Campaign Stakeholder Management
(define-map campaign-contributors
  { campaign-id: uint }
  { contributor-list: (list 500 principal) }
)

;; READ-ONLY FUNCTIONS

;; Retrieve comprehensive campaign details
(define-read-only (get-campaign (campaign-id uint))
  (map-get? campaigns { campaign-id: campaign-id })
)

;; Query contributor investment information
(define-read-only (get-contribution
    (campaign-id uint)
    (contributor principal)
  )
  (map-get? contributions {
    campaign-id: campaign-id,
    contributor: contributor,
  })
)

;; Get total platform campaign count
(define-read-only (get-campaign-count)
  (var-get campaign-counter)
)

;; Retrieve current platform fee structure
(define-read-only (get-platform-fee-rate)
  (var-get platform-fee-rate)
)

;; Validate campaign active status
(define-read-only (is-campaign-active (campaign-id uint))
  (match (get-campaign campaign-id)
    campaign (and
      (is-eq (get status campaign) STATUS_ACTIVE)
      (< stacks-block-height (get deadline-height campaign))
    )
    false
  )
)

;; Check campaign funding goal achievement
(define-read-only (is-campaign-successful (campaign-id uint))
  (match (get-campaign campaign-id)
    campaign (>= (get raised campaign) (get goal campaign))
    false
  )
)

;; Calculate platform fee for transaction
(define-read-only (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee-rate)) u10000)
)

;; Query contributor voting participation
(define-read-only (get-vote-status
    (campaign-id uint)
    (voter principal)
  )
  (map-get? contributor-votes {
    campaign-id: campaign-id,
    voter: voter,
  })
)