# MintAso - NFT Marketplace

## Introduction

**MintAso** is a decentralized NFT (Non-Fungible Token) marketplace built on the Stacks blockchain. It allows users to mint, buy, sell, and trade unique digital assets. With a focus on security, transparency, and ease of use, MintAso enables creators, collectors, and traders to participate in the growing world of NFTs.

## Features

- **Mint NFTs:** Create your own NFTs with metadata that includes links to artwork, media, or any other digital assets.
- **Buy & Sell:** Easily list your NFTs for sale or purchase NFTs from other users.
- **Ownership & Transfers:** NFT ownership is fully decentralized and can be easily transferred between users.
- **Marketplace Fees:** A configurable marketplace fee for transactions.
- **Paused Marketplace:** Ability to pause the marketplace for maintenance or updates.
- **Secure Transactions:** All payments and NFT transfers are secured on the blockchain.

## Technology Stack

- **Blockchain:** Stacks Blockchain
- **Smart Contracts:** Clarity Language
- **NFT Standard:** SIP-009 (Stacks NFT Standard)

## Smart Contract Overview

MintAso’s smart contract is designed to handle minting, listing, buying, and transferring NFTs efficiently and securely. Below is a brief overview of the core functionality:

- **Mint Functionality:** Users can mint new NFTs by providing a metadata URL. The minted NFT is assigned a unique token ID and stored on the blockchain.
- **Token Transfers:** Owners can transfer their NFTs to other users. Only the current owner can initiate a transfer.
- **Listing NFTs:** Users can list NFTs for sale by specifying a price and expiry date.
- **Purchasing NFTs:** Buyers can purchase listed NFTs by paying the listed price. The marketplace deducts a small transaction fee from each sale.
- **Paused Marketplace:** The marketplace can be paused by the contract owner in case of updates or emergencies, preventing transactions during that period.

## Smart Contract Functions

### 1. `mint(metadata-url (string-utf8 256))`
- Mint a new NFT with the specified metadata URL.
- Returns the token ID of the minted NFT.

### 2. `transfer(token-id uint, sender principal, recipient principal)`
- Transfer a specific token from the sender to the recipient.
- Only the owner of the token can initiate a transfer.

### 3. `list-token(token-id uint, price uint, expiry uint)`
- List an NFT for sale with a set price and expiry date.
- Only the owner of the token can list it.

### 4. `unlist-token(token-id uint)`
- Remove a listed NFT from the marketplace.

### 5. `buy-token(token-id uint)`
- Purchase a listed NFT by paying the required price.

### 6. `set-marketplace-fee(new-fee uint)`
- Update the marketplace fee, controlled by the contract owner.

### 7. `toggle-marketplace-pause()`
- Pause or unpause the marketplace, controlled by the contract owner.

## Getting Started

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) (For testing and deploying smart contracts)
- [Stacks CLI](https://docs.stacks.co/understand-stacks/technical-specs#cli) (For interacting with the Stacks blockchain)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Rachiee/mintaso.git
   cd mintaso
   ```

2. Install dependencies:
   ```bash
   clarinet install
   ```

### Deployment

1. Compile the smart contract:
   ```bash
   clarinet check
   ```

2. Deploy the smart contract:
   ```bash
   clarinet deploy
   ```

3. Interact with the smart contract through the Stacks CLI or your preferred tool.

### Running Tests

You can run unit tests to ensure that all functionalities work as expected:

```bash
clarinet test
```

## Contributing

We welcome contributions to **MintAso**. If you would like to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Submit a pull request with a detailed description of your changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For any inquiries or support, feel free to reach out to the project maintainers at [rachi7ace@gmail.com].
