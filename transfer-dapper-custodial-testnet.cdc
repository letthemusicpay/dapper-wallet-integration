import NonFungibleToken from 0x631e88ae7f1d7c20
import RCRDSHPNFT from 0x7cde1ed9dfd13561

transaction(withdrawIDs: [UInt64]) {
  prepare(acct: AuthAccount) {
    let recipient = getAccount(0x867a1aceded567a6)
    let collectionRef = acct.borrow<&RCRDSHPNFT.Collection>(from: RCRDSHPNFT.collectionStoragePath)?? panic("Could not borrow a reference to the owner's collection")
    let depositRef = recipient.getCapability(RCRDSHPNFT.collectionPublicPath).borrow<&{NonFungibleToken.CollectionPublic}>()?? panic("Could not borrow a reference to the receiver's collection")

    for withdrawID in withdrawIDs {
      let nft <- collectionRef.withdraw(withdrawID: withdrawID)
      depositRef.deposit(token: <-nft)
    }
  }
}
