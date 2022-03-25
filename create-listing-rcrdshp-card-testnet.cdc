import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0x82ec283f88a62e65
import NFTStorefront from 0x94b06cfca1d8a476
import RCRDSHPNFT from 0x7cde1ed9dfd13561

// This transaction can be used to place and NFT for sale on a marketplace such that a specified percentage of the proceeds of the sale
// go to the dapp as a royalty.
transaction(saleItemID: UInt64, saleItemPrice: UFix64) {
    let sellerPaymentReceiver: Capability<&{FungibleToken.Receiver}>
    let nftProvider: Capability<&RCRDSHPNFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront

    // It's important that the dapp account authorize this transaction so the dapp as the ability
    // to validate and approve the royalty included in the sale.
    prepare(seller: AuthAccount) {
        // If the account doesn't already have a storefront, create one and add it to the account
        if seller.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath) == nil {
            let newstorefront <- NFTStorefront.createStorefront() as! @NFTStorefront.Storefront
            seller.save(<-newstorefront, to: NFTStorefront.StorefrontStoragePath)
            seller.link<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath,
                target: NFTStorefront.StorefrontStoragePath
            )
        }

        // Get a reference to the receiver that will receive the fungible tokens if the sale executes.
        self.sellerPaymentReceiver = seller.getCapability<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver)
        assert(self.sellerPaymentReceiver.borrow() != nil, message: "Missing or mis-typed DapperUtilityCoin receiver")

        // If the user does not have their collection linked to their account, link it.
        let nftProviderPrivatePath = /private/RCRDSHPNFTCollectionProviderForNFTStorefront
        let hasLinkedCollection = seller.getCapability<&RCRDSHPNFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(
                nftProviderPrivatePath
            )!.check()
        if !hasLinkedCollection {
            seller.link<&RCRDSHPNFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(
                nftProviderPrivatePath,
                target: RCRDSHPNFT.collectionStoragePath
            )
        }

        // Get a capability to access the user's NFT collection.
        self.nftProvider = seller.getCapability<&RCRDSHPNFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(
                nftProviderPrivatePath
            )!
        assert(self.nftProvider.borrow() != nil, message: "Missing or mis-typed collection provider")

        // Get a reference to the user's NFT storefront
        self.storefront = seller.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")

        // Make sure this NFT is not already listed for sale in this storefront.
        let existingOffers = self.storefront.getListingIDs()
        if existingOffers.length > 0 {
            for listingResourceID in existingOffers {
                let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}? = self.storefront.borrowListing(listingResourceID: listingResourceID)
                if listing != nil && listing!.getDetails().nftID == saleItemID && listing!.getDetails().nftType == Type<@RCRDSHPNFT.NFT>(){
                    self.storefront.removeListing(listingResourceID: listingResourceID)
                }
            }
        }
    }

    execute {
       // Calculate the amout the seller should receive if the sale executes, and the amount
       // that should be sent to the dapp as a royalty.
       let amountSeller = saleItemPrice * 0.875 // 87.5% to the seller
       let amountRoyalty = saleItemPrice - amountSeller // 12.5% to the dapp

        // Get the royalty recipient's public account object
        let royaltyRecipient = getAccount(0x04ace4812546a5dd) // dapper-wallet-stg@ltmp.co

        // Get a reference to the royalty recipient's Receiver
        let royaltyReceiverRef = royaltyRecipient.getCapability<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver)
        assert(royaltyReceiverRef.borrow() != nil, message: "Missing or mis-typed DapperUtilityCoin royalty receiver")

        let saleCutSeller = NFTStorefront.SaleCut(
            receiver: self.sellerPaymentReceiver,
            amount: amountSeller
        )

        let saleCutRoyalty = NFTStorefront.SaleCut(
            receiver: royaltyReceiverRef,
            amount: amountRoyalty
        )

        self.storefront.createListing(
            nftProviderCapability: self.nftProvider,
            nftType: Type<@RCRDSHPNFT.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@DapperUtilityCoin.Vault>(),
            saleCuts: [saleCutSeller, saleCutRoyalty]
        )
    }
}
