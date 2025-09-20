# BitCrowd Protocol

**Next-Generation Decentralized Crowdfunding Platform on Stacks**
*Secured by Bitcoin’s immutable ledger*

BitCrowd revolutionizes the crowdfunding ecosystem by removing traditional intermediaries and enabling **direct creator–backer interactions** through trustless smart contracts. The protocol ensures **security, transparency, and fairness** by leveraging the Bitcoin-secured Stacks blockchain.

---

## 🚀 System Overview

BitCrowd provides a **fully decentralized crowdfunding platform** with the following guarantees:

* **Trustless Escrow** – All contributions are held securely in-contract until campaigns are finalized.
* **Community Governance** – Stakeholders vote on fund disbursements for campaigns with governance enabled.
* **Milestone-Based Disbursements** – Fund releases are gated by campaign success and voting approvals.
* **Automatic Refunds** – Backers automatically reclaim funds if a campaign fails or is cancelled.
* **Dynamic Fee Model** – Platform fee (default: 2.5%) is configurable by protocol governance with strict upper bounds.
* **Robust Validation** – Campaign inputs, contributions, and governance actions are strictly validated to prevent misuse.

---

## 🏗 Contract Architecture

The contract is designed around **clear separation of state, logic, and governance**:

### **1. Global State**

* `campaign-counter`: Total campaigns created.
* `platform-fee-rate`: Current platform fee (basis points, capped at 10%).

### **2. Core Data Maps**

* **Campaigns** – Registry of all campaigns with metadata and lifecycle states.
* **Contributions** – Tracks each backer’s contributions, refunds, and voting power.
* **Contributor Votes** – Governance voting per campaign with weighted voting.
* **Campaign Contributors** – Contributor list capped at 500 addresses per campaign.

### **3. Campaign Lifecycle**

* **Active → Successful** (goal met after deadline)
* **Active → Failed** (goal not met after deadline)
* **Active → Cancelled** (creator or admin cancellation)

### **4. Governance**

* Weighted voting based on contribution amounts.
* Voting occurs **post-campaign deadline** within a configurable window.
* Fund disbursement requires majority approval if governance is enabled.

---

## 🔄 Data Flow

Below is a high-level view of interactions:

```
[ Backer ] -- contribute() --> [ Campaign Escrow ]
     |                                |
     |---- request-refund() ----------|
     |                                |
     |---- vote() ------------------->|---+--> [ Governance Decision ]
                                      |
[ Creator ] -- claim-funds() ---------+------> [ Fund Disbursement + Fee ]
```

1. **Contributions** are escrowed in the contract.
2. After campaign expiry:

   * If **successful**, creator can claim funds (subject to governance).
   * If **failed/cancelled**, backers request refunds.
3. **Governance votes** (if enabled) determine final fund disbursement outcome.

---

## 📜 Key Functions

### **Campaign Management**

* `create-campaign(...)` – Launch a new campaign.
* `cancel-campaign(campaign-id)` – Creator cancels their campaign.

### **Contributions**

* `contribute(campaign-id, amount)` – Contribute STX to a campaign.
* `request-refund(campaign-id)` – Refund backers if campaign fails.

### **Funds & Governance**

* `claim-funds(campaign-id)` – Creator claims funds (if successful).
* `vote(campaign-id, vote-for)` – Stakeholder votes for/against fund release.

### **Admin Controls**

* `set-platform-fee-rate(new-rate)` – Adjust fee (max 10%).
* `emergency-pause-campaign(campaign-id)` – Emergency intervention by contract owner.

---

## ⚙️ Error Codes

The protocol defines a **comprehensive error registry** for predictable handling:

* `u100` – Unauthorized
* `u101` – Campaign not found
* `u102` – Campaign ended
* `u103` – Campaign still active
* `u104` – Goal not met
* `u105` – Already refunded
* `u106` – No contribution
* `u107` – Invalid amount
* `u108` – Invalid parameters
* `u109` – Voting period ended
* `u110` – Already voted
* `u111` – Insufficient voting power
* `u112` – Contributor list full
* `u113` – Invalid string input

---

## 🔐 Security Considerations

* **Escrow Integrity** – All STX remain locked until explicit state transitions.
* **Immutable Validation** – Campaign IDs, contribution amounts, and voting rights are fully validated.
* **Fee Cap Enforcement** – Prevents excessive platform fees.
* **Emergency Intervention** – Admin can pause campaigns only in emergencies.

---

## 📈 Scalability

* **Campaign ID cap**: `1,000,000` campaigns supported.
* **Duration flexibility**: Campaigns can last from **1 day → \~100 days**.
* **Contributor cap**: Up to `500` unique contributors per campaign.
* **Voting duration**: Up to `~10 days`.

---

## ✅ Usage Example

```clarity
;; Create campaign
(contract-call? .bitcrowd create-campaign
  "Open-Source Project"
  "Building decentralized crowdfunding tools"
  u10000000   ;; goal: 10M STX
  u7200       ;; duration: ~50 days
  true        ;; voting enabled
  u1440       ;; voting duration: ~10 days
  u1000       ;; min contribution: 1000 STX
)

;; Contribute
(contract-call? .bitcrowd contribute u1 u2000)

;; Vote (after campaign deadline)
(contract-call? .bitcrowd vote u1 true)

;; Creator claims funds
(contract-call? .bitcrowd claim-funds u1)
```

---

## 🧩 Deployment Notes

* Ensure the contract owner wallet is a **secure multisig** to minimize governance risk.
* Recommended to integrate with a **frontend dashboard** for campaign discovery, contribution tracking, and voting visualization.
* Consider off-chain indexing (e.g., Hiro API or custom indexer) for scalable UI/UX.

---

## 📚 License

This protocol is released under the **MIT License**.
