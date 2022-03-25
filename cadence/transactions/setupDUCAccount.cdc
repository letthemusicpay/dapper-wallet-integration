import FungibleToken from 0xee82856bf20e2aa6
import DapperUtilityCoin from 0xf8d6e0586b0a20c7

transaction {
    prepare(signer: AuthAccount) {
        if signer.borrow<&DapperUtilityCoin.Vault>(from: /storage/dapperUtilityCoinVault) != nil {
            return
        }

        signer.save(
            <-DapperUtilityCoin.createEmptyVault(),
            to: /storage/dapperUtilityCoinVault
        )

        signer.link<&DapperUtilityCoin.Vault{FungibleToken.Receiver}>(
            /public/dapperUtilityCoinReceiver,
            target: /storage/dapperUtilityCoinVault
        )

        signer.link<&DapperUtilityCoin.Vault{FungibleToken.Balance}>(
            /public/dapperUtilityCoinBalance,
            target: /storage/dapperUtilityCoinVault
        )
    }
}
