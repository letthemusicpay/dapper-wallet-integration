import NonFungibleToken from 0xf8d6e0586b0a20c7
import RCRDSHPNFT from 0xe03daebed8ca0615

pub fun main(account: Address): [UInt64] {
  let collectionRef = getAccount(account)
      .getCapability(/public/RCRDSHPNFTCollection)
      .borrow<&{NonFungibleToken.CollectionPublic}>()
      ?? panic("Could not borrow capability from public collection")
  return collectionRef.getIDs()
}
