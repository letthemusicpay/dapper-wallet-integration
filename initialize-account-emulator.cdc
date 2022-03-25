import NonFungibleToken from 0xf8d6e0586b0a20c7
import RCRDSHPNFT from 0xe03daebed8ca0615

// This transaction initializes an account with a collection that allows it to hold NFTs from a specific contract. It will
// do nothing if the account is already initialized.
transaction {
    prepare(collector: AuthAccount) {
        if collector.borrow<&RCRDSHPNFT.Collection{NonFungibleToken.Receiver}>(from: RCRDSHPNFT.collectionStoragePath) == nil {
            let collection <- RCRDSHPNFT.createEmptyCollection() as! @RCRDSHPNFT.Collection
            collector.save(<-collection, to: RCRDSHPNFT.collectionStoragePath)
            collector.link<&RCRDSHPNFT.Collection{NonFungibleToken.CollectionPublic, RCRDSHPNFT.RCRDSHPNFTCollectionPublic}>(
                RCRDSHPNFT.collectionPublicPath,
                target: RCRDSHPNFT.collectionStoragePath,
            )
        }
    }
}
