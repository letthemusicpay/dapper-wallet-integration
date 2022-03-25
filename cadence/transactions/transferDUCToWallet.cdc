import FungibleToken from 0xee82856bf20e2aa6
import DapperUtilityCoin from 0xf8d6e0586b0a20c7

transaction(address: Address, amount: UFix64) {
  let tokenAdmin: &DapperUtilityCoin.Administrator
  let tokenReceiver: &{FungibleToken.Receiver}

  prepare(signer: AuthAccount) {
		self.tokenAdmin = signer
		  .borrow<&DapperUtilityCoin.Administrator>(from: /storage/dapperUtilityCoinAdmin)
		  ?? panic("Signer is not the token admin")

		self.tokenReceiver = getAccount(address)
		  .getCapability(/public/dapperUtilityCoinReceiver)!
		  .borrow<&{FungibleToken.Receiver}>()
		  ?? panic("Unable to borrow receiver reference")
	}

	execute {
		let minter <- self.tokenAdmin.createNewMinter(allowedAmount: amount)
		let mintedVault <- minter.mintTokens(amount: amount)

		self.tokenReceiver.deposit(from: <-mintedVault)

		destroy minter
	}
}
