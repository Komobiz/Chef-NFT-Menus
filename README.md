# 👨‍🍳 Chef NFT Menus

A revolutionary smart contract platform where chefs can tokenize their signature dishes as NFTs, and holders can redeem them for exclusive dining experiences or private cooking classes.

## 🌟 Features

- **👨‍🍳 Chef Registration**: Chefs can register and get verified on the platform
- **🍽️ NFT Minting**: Create unique NFTs for signature dishes with detailed metadata
- **🎫 Experience Redemption**: NFT holders can redeem tokens for real-world dining experiences
- **💰 Chef Earnings**: Automatic tracking of chef earnings from redemptions
- **📊 Bulk Operations**: Mint multiple menu NFTs in a single transaction
- **🔒 Access Control**: Secure chef verification and menu management

## 🚀 Quick Start

### Prerequisites
- Clarinet installed
- Stacks wallet for testing

### Installation
```bash
git clone https://github.com/your-repo/Chef-NFT-Menus
cd Chef-NFT-Menus
clarinet check
```

## 📋 Contract Functions

### 🔐 Chef Management
```clarity
;; Register as a chef
(register-chef "Chef Name" "Restaurant Name")

;; Verify chef (owner only)
(verify-chef 'SP1CHEF...)
```

### 🍽️ NFT Operations
```clarity
;; Mint a single menu NFT
(mint-menu-nft 
  "Signature Pasta" 
  "Handmade pasta with secret family sauce"
  u1000000  ;; price in microSTX
  "dining"  ;; experience type
  u5        ;; max redemptions
  'SP1RECIPIENT...)

;; Bulk mint multiple NFTs
(bulk-mint-menus 
  (list "Dish1" "Dish2")
  (list "Desc1" "Desc2") 
  (list u1000 u2000)
  (list "dining" "class")
  (list u5 u3)
  (list 'SP1... 'SP2...))
```

### 🎫 Redemption System
```clarity
;; Redeem NFT for experience
(redeem-experience u1)

;; Check if NFT can be redeemed
(can-redeem u1)
```

### 📊 Information Queries
```clarity
;; Get chef information
(get-chef-info 'SP1CHEF...)

;; Get menu details
(get-menu-details u1)

;; Get redemption status
(get-redemption-status u1)

;; Get chef earnings
(get-chef-earnings 'SP1CHEF...)
```

## 💡 Usage Examples

### For Chefs 👨‍🍳

1. **Register on the platform**:
```clarity
(contract-call? .Chef-NFT-Menus register-chef "Gordon Ramsay" "Hell's Kitchen")
```

2. **Wait for verification** (done by contract owner)

3. **Mint your signature dish NFT**:
```clarity
(contract-call? .Chef-NFT-Menus mint-menu-nft 
  "Beef Wellington" 
  "My legendary beef wellington with perfect pastry"
  u5000000  ;; 5 STX
  "private-dining"
  u10
  tx-sender)
```

### For NFT Holders 🎫

1. **Purchase NFT** (through marketplace or direct mint)

2. **Redeem for experience**:
```clarity
(contract-call? .Chef-NFT-Menus redeem-experience u1)
```

3. **Check redemption eligibility**:
```clarity
(contract-call? .Chef-NFT-Menus can-redeem u1)
```

## 🏗️ Contract Architecture

### Data Structures

- **Chefs**: Store chef profiles with verification status
- **Menu Details**: NFT metadata including dish info and redemption limits  
- **Token Redemptions**: Track redemption status and history
- **Chef Earnings**: Accumulated earnings from redemptions

### Key Constants
- `err-owner-only (u100)`: Only contract owner can perform action
- `err-not-chef (u101)`: Caller is not a registered chef
- `err-not-token-owner (u102)`: Caller doesn't own the token
- `err-already-redeemed (u104)`: Token already redeemed

## 🔧 Testing

```bash
clarinet test
```

Run specific test:
```bash
clarinet test --filter test-mint-menu-nft
```

## 🌐 Deployment

1. **Testnet**:
```bash
clarinet deploy --network testnet
```

2. **Mainnet**:
```bash
clarinet deploy --network mainnet
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🎯 Roadmap

- [ ] 🖼️ Enhanced metadata with IPFS integration
- [ ] 🏪 Built-in marketplace functionality  
- [ ] ⭐ Rating and review system
- [ ] 📱 Mobile app integration
- [ ] 🌍 Multi-chain support

## 📞 Support

- 📧 Email: support@chef-nft-menus.com
- 💬 Discord: [Join our community](https://discord.gg/chef-nft)
- 🐦 Twitter: [@ChefNFTMenus](https://twitter.com/ChefNFTMenus)

---

Made with ❤️ by the Chef NFT Menus team
