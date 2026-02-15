# Atomic Token Vesting Vault

This repository contains a secure, audited-style Smart Contract for managing token distributions. It is ideal for Web3 projects that need to lock team or investor tokens and release them gradually over time to prevent market dumping.

### Features
* **Cliff Period:** Set a specific duration before any tokens become withdrawable.
* **Linear Vesting:** Tokens unlock second-by-second after the cliff, ensuring a smooth distribution curve.
* **Revocable Schedules:** Optional functionality for founders to reclaim unvested tokens if a team member leaves.
* **Gas Efficient:** Optimized to handle multiple vesting schedules within a single contract instance.

### Vesting Logic
1. **Deployment:** The contract is initialized with the target ERC-20 token address.
2. **Creation:** An admin creates a schedule defining the `start`, `cliff`, `duration`, and `totalAmount`.
3. **Release:** The beneficiary calls `release()` to claim only the tokens that have vested up to that timestamp.

### License
MIT
