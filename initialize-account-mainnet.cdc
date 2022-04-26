import NonFungibleToken from 0x1d7e57aa55817448
import RCRDSHPNFT from 0x6c3ff40b90b928ab

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
