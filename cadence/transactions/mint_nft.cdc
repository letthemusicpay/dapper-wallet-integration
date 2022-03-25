import NonFungibleToken from 0xf8d6e0586b0a20c7
import RCRDSHPNFT from 0xe03daebed8ca0615

transaction(recipient: Address, meta: {String: String}) {
  let minter: &RCRDSHPNFT.NFTMinter

  prepare(signer: AuthAccount) {
      self.minter = signer.borrow<&RCRDSHPNFT.NFTMinter>(from: RCRDSHPNFT.minterStoragePath)?? panic("Could not borrow a reference to the NFT minter")
  }

  execute {
    let receiver = getAccount(recipient)
        .getCapability(RCRDSHPNFT.collectionPublicPath)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not get receiver reference to the NFT Collection")

    self.minter.mintNFT(recipient: receiver, meta: meta)
  }
}
