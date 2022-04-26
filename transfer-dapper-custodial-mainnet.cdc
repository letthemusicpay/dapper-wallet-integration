import NonFungibleToken from 0x1d7e57aa55817448
import RCRDSHPNFT from 0x6c3ff40b90b928ab

transaction(withdrawIDs: [UInt64]) {
  prepare(acct: AuthAccount) {
    let recipient = getAccount(0x2a621e8f4d43702d)
    let collectionRef = acct.borrow<&RCRDSHPNFT.Collection>(from: RCRDSHPNFT.collectionStoragePath)?? panic("Could not borrow a reference to the owner's collection")
    let depositRef = recipient.getCapability(RCRDSHPNFT.collectionPublicPath).borrow<&{NonFungibleToken.CollectionPublic}>()?? panic("Could not borrow a reference to the receiver's collection")

    for withdrawID in withdrawIDs {
      let nft <- collectionRef.withdraw(withdrawID: withdrawID)
      depositRef.deposit(token: <-nft)
    }
  }
}
