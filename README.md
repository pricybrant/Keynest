# Keynest

A decentralized smart wallet infrastructure for secure key management, social recovery, and trustless crypto inheritance — all powered by Clarity smart contracts on the Stacks blockchain.

---

## Overview

Keynest consists of ten modular smart contracts that work together to provide a robust, user-friendly self-custody experience with recoverability, inheritance, and advanced permission control:

1. **Vault Wallet Factory** – Deploys and manages upgradeable smart wallets for users.
2. **Vault Wallet** – A programmable user wallet with modular plug-in support.
3. **Guardian Manager** – Handles guardian registration, rotation, and consensus recovery logic.
4. **Recovery Module** – Enables wallet recovery using guardian votes or pre-defined rules.
5. **Key Rotation Manager** – Supports secure and time-locked key updates.
6. **Inheritance Module** – Transfers assets to heirs based on pre-defined inheritance logic.
7. **Dead Man’s Switch** – Automates asset handling based on wallet inactivity signals.
8. **Role Permission Registry** – Grants granular access and spending controls to delegates.
9. **Fee Manager** – Enables meta-transactions and flexible fee abstraction.
10. **Compliance Oracle Interface** – Optional integration with off-chain legal or identity oracles.

---

## Features

- **Social and multi-signature recovery** to prevent permanent loss  
- **Dead man’s switch** for wallet inactivity and crypto estate execution  
- **Trustless inheritance** without lawyers or custodians  
- **Key rotation** with delay-based rollback protection  
- **Granular permissions** for smart wallet delegation  
- **Fee abstraction and meta-tx support** for smoother UX  
- **Modular architecture** for plug-and-play wallet extensions  
- **On-chain guardian consensus** with dispute protection  
- **Proof-of-life oracles** for posthumous execution  
- **Clarity-powered, transparent logic** on the Stacks blockchain  

---

## Smart Contracts

### Vault Wallet Factory
- Deploys user-specific smart wallets
- Maintains registry of deployed wallets
- Uses upgradeable architecture (via traits or wrapper contracts)

### Vault Wallet
- Core user wallet with modular permissions
- Stores assets, calls plug-in modules
- Interface for key-based or delegated access

### Guardian Manager
- Register/remove guardians with threshold setting
- Enforces multi-guardian approval for recovery
- Emits recovery-related events

### Recovery Module
- Allows wallet ownership to be reset if consensus is met
- Time delay and anti-spam protection
- Supports both social and automated triggers

### Key Rotation Manager
- Initiates time-locked key change requests
- Cancels or confirms based on defined grace period
- Ensures old key revocation is verifiable

### Inheritance Module
- Designate heirs and distribution logic
- Activates upon oracle verification or inactivity
- Supports encrypted metadata for off-chain wills

### Dead Man’s Switch
- Monitors wallet inactivity
- Triggers inheritance or freezes wallet after timeout
- User can reset by proving life or activity

### Role Permission Registry
- Assigns and revokes wallet roles (e.g., spending, signing)
- Time-bound permissions with expiration logic
- Event logs for all permission changes

### Fee Manager
- Allows meta-transactions (signed by user, relayed by third party)
- Fee abstraction through STX or other tokens
- Configurable gas sponsorship by dApps or DAOs

### Compliance Oracle Interface
- Optional KYC/AML or proof-of-death triggers
- Allows inheritance based on off-chain events
- Pluggable oracle design using traits

---

## Installation

1. Install [Clarinet CLI](https://docs.hiro.so/clarinet/getting-started)
2. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/keynest.git
   ```
3. Run tests:
    ```
    npm test
    ```
4. Deploy contracts:
    ```
    clarinet deploy
    ```

---

## Usage

- Keynest smart contracts are designed to be modular. Developers can:
- Integrate only the Vault Wallet + Guardian Manager for minimal social recovery
- Add the Inheritance Module for estate planning
- Use Role Permission Registry to build secure DAO-controlled wallets or multi-delegate treasuries
- Refer to individual contract documentation for traits, functions, and integration steps.

---

## License

MIT License