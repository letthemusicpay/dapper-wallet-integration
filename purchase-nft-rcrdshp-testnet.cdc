import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0x82ec283f88a62e65
import NFTStorefront from 0x94b06cfca1d8a476
import MetadataViews from 0x631e88ae7f1d7c20
import RCRDSHPNFT from 0x7cde1ed9dfd13561

// This transaction purchases an NFT on a peer-to-peer marketplace (i.e. **not** directly from a dapp). This transaction
// will also initialize the buyer's NFT collection on their account if it has not already been initialized.
transaction(listingResourceID: UInt64, storefrontAddress: Address, expectedPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let nftCollection: &RCRDSHPNFT.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}
    let salePrice: UFix64
    let balanceBeforeTransfer: UFix64
    let mainDapperUtilityCoinVault: &DapperUtilityCoin.Vault

    prepare(dapper: AuthAccount, buyer: AuthAccount) {
        // Initialize the buyer's collection if they do not already have one
        if buyer.borrow<&RCRDSHPNFT.Collection{NonFungibleToken.Receiver}>(from: RCRDSHPNFT.collectionStoragePath) == nil {
            let collection <- RCRDSHPNFT.createEmptyCollection() as! @RCRDSHPNFT.Collection
            buyer.save(<-collection, to: RCRDSHPNFT.collectionStoragePath)
            buyer.link<&RCRDSHPNFT.Collection{NonFungibleToken.CollectionPublic, RCRDSHPNFT.RCRDSHPNFTCollectionPublic, MetadataViews.ResolverCollection}>(
               RCRDSHPNFT.collectionPublicPath,
               target: RCRDSHPNFT.collectionStoragePath,
           )
        }

        // Get the storefront reference from the seller
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        // Get the listing by ID from the storefront
        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
            ?? panic("No Offer with that ID in Storefront")
        self.salePrice = self.listing.getDetails().salePrice

        // Get a DUC vault from Dapper's account
        self.mainDapperUtilityCoinVault = dapper.borrow<&DapperUtilityCoin.Vault>(from: /storage/dapperUtilityCoinVault)
            ?? panic("Cannot borrow DapperUtilityCoin vault from account storage")
        self.balanceBeforeTransfer = self.mainDapperUtilityCoinVault.balance
        self.paymentVault <- self.mainDapperUtilityCoinVault.withdraw(amount: self.salePrice)

        // Get the collection from the buyer so the NFT can be deposited into it
        self.nftCollection = buyer.borrow<&RCRDSHPNFT.Collection{NonFungibleToken.Receiver}>(
            from: RCRDSHPNFT.collectionStoragePath
        ) ?? panic("Cannot borrow NFT collection receiver from account")
    }

    // Check that the price is right
    pre {
        self.salePrice == expectedPrice: "unexpected price"
    }

    execute {
        let item <- self.listing.purchase(
            payment: <-self.paymentVault
        )

        self.nftCollection.deposit(token: <-item)

        // Remove listing-related information from the storefront since the listing has been purchased.
        self.storefront.cleanup(listingResourceID: listingResourceID)
    }

    // Check that all dapperUtilityCoin was routed back to Dapper
    post {
        self.mainDapperUtilityCoinVault.balance == self.balanceBeforeTransfer: "DapperUtilityCoin leakage"
    }
}
