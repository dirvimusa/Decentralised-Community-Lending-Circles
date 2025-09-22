# 🎯 Decentralised Community Lending Circles

A decentralised smart contract implementation of traditional community lending circles (susus/tandas/chit funds) on the Stacks blockchain using Clarity.

## 🌟 Overview

Community lending circles are informal financial cooperatives where groups of people pool their money together and take turns receiving the collected amount. This smart contract brings this time-tested financial mechanism to the blockchain, enabling trustless and transparent community lending.

## ✨ Features

- 🔧 **Create Lending Circles**: Set up new lending circles with custom contribution amounts and member limits
- 👥 **Join Circles**: Community members can join existing lending circles  
- 🔄 **Manage Rounds**: Circle creators can start new funding rounds
- 💰 **Contribute Funds**: Members contribute STX to active rounds
- 🎯 **Select Recipients**: Fair recipient selection for fund distribution
- 📤 **Distribute Payouts**: Automated payout distribution to selected recipients
- 🔒 **Circle Management**: Close circles when lending cycles complete

## 🚀 Quick Start

### Prerequisites

- [Clarinet CLI](https://docs.hiro.so/stacks/clarinet) installed
- Basic understanding of Stacks and Clarity

### Installation

```bash
git clone <your-repo-url>
cd Decentralised-Community-Lending-Circles
clarinet check
```

### Testing

```bash
npm install
npm test
```

## 📖 Usage Guide

### Creating a Lending Circle

```clarity
(contract-call? .Decentralised-Community-Lending-Circles create-circle "My Circle" u1000000 u5)
```
- **name**: Circle name (max 64 characters)
- **contribution-amount**: Amount each member contributes per round (in microSTX)
- **max-members**: Maximum number of members (3-20)

### Joining a Circle

```clarity
(contract-call? .Decentralised-Community-Lending-Circles join-circle u1)
```

### Starting a New Round

```clarity
(contract-call? .Decentralised-Community-Lending-Circles start-new-round u1)
```

### Contributing to a Round

```clarity
(contract-call? .Decentralised-Community-Lending-Circles contribute-to-round u1)
```

### Selecting a Recipient

```clarity
(contract-call? .Decentralised-Community-Lending-Circles select-recipient u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Distributing Payout

```clarity
(contract-call? .Decentralised-Community-Lending-Circles distribute-payout u1)
```

## 🔍 Read-Only Functions

### Get Circle Information
```clarity
(contract-call? .Decentralised-Community-Lending-Circles get-circle u1)
```

### Get Member Information
```clarity
(contract-call? .Decentralised-Community-Lending-Circles get-circle-member u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Get Round Information
```clarity
(contract-call? .Decentralised-Community-Lending-Circles get-round u1)
```

## 🏗️ Contract Architecture

### Data Structures

- **Circles**: Core lending circle information
- **Circle Members**: Member tracking and payout status
- **Rounds**: Funding round details and recipient selection
- **Contributions**: Individual member contributions per round
- **Member List**: Indexed member listing for efficient iteration

### Key Functions

- `create-circle`: Initialize new lending circles
- `join-circle`: Add members to existing circles
- `start-new-round`: Begin new funding rounds
- `contribute-to-round`: Process member contributions
- `select-recipient`: Choose round recipients
- `distribute-payout`: Transfer funds to recipients
- `close-circle`: Deactivate completed circles

## 🛡️ Security Features

- ✅ Authorization checks for circle creators
- ✅ Duplicate contribution prevention
- ✅ Member validation and circle capacity limits
- ✅ Payout tracking to prevent double-spending
- ✅ Active circle and round status validation
- ✅ Sufficient fund verification before distribution

## ⚠️ Error Codes

| Code | Error | Description |
|------|-------|-----------|
| u401 | ERR-NOT-AUTHORIZED | Caller not authorized for this action |
| u404 | ERR-NOT-FOUND | Requested resource does not exist |
| u405 | ERR-INVALID-AMOUNT | Invalid contribution amount or member count |
| u407 | ERR-CIRCLE-FULL | Circle has reached maximum capacity |
| u408 | ERR-ALREADY-MEMBER | User already a member of this circle |
| u409 | ERR-NOT-MEMBER | User is not a member of this circle |
| u410 | ERR-CIRCLE-NOT-ACTIVE | Circle is not currently active |
| u411 | ERR-CONTRIBUTION-EXISTS | User has already contributed to this round |
| u412 | ERR-ROUND-NOT-ACTIVE | Round is not currently active |
| u413 | ERR-ALREADY-RECEIVED-PAYOUT | Member has already received payout |
| u414 | ERR-INSUFFICIENT-CONTRIBUTIONS | Not enough contributions collected |


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


Made with ❤️ for decentralized finance and community empowerment



