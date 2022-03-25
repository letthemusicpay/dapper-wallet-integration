# Whitelisting transactions test

## USE CASE: Configure all the accounts with the needed contracts
### 1. Start the emulator and deploy the base contracts
We are going to run the emulator in persist mode so we dont need to re run all the account creation each time we start the emulator

```
flow emulator start --persist --contracts -v
flow project deploy --network emulator
```

and wait to see this messages in the terminal

```
% flow project deploy --network emulator

Deploying 4 contracts for accounts: emulator-account

NonFungibleToken -> 0xf8d6e0586b0a20c7 (339a06ed99d530bf926afc2ed921211a601d77f4d19b119fc4b084a498826a8f)

MetadataViews -> 0xf8d6e0586b0a20c7 (aa990c06a9fcb84037e2af1b77a395693b24d54afdca2567cf2571b95f494f0d)

TokenForwarding -> 0xf8d6e0586b0a20c7 (2c46d41c266f918011c8e933ee9a30eb3710a84601a184609905d90262cd4a52)

NFTStorefront -> 0xf8d6e0586b0a20c7 (d911501e43249a58feca4cc1566f9fa39d62300be37ea694d9568e1a7194e698)

DapperUtilityCoin -> 0xf8d6e0586b0a20c7 (3bb690ee77a3dbc2c0aa367505b3bb3797741eb3444f057c8d248df93a8bcd93)

✨ All contracts deployed successfully

```

### 2. Create all the needed accounts
Using the following key pairs: 
```
{"private":"3bc524119d2571a4b5691ca695ae5061bda8f4c7302371bc5c3f7d86ecbee4d4","public":"f691abdb945ac166fbe5f1a06e3ebe6eaa77061099a796175efcdf661b6c76491ba116420fb51ae3f52c973474f96f25f88c57812ed95f4df1add3cf6fd89f1c"}
{"private":"5edefdd0317d3a11acf9004554cfd1730e066623506325ae4016ea0eecb4bddd","public":"fbbbbec5eeff5b669f08fd7be22d51dd855afc500cccff6a0274b1075d2bb2c6f53a2ef3d512fc7c339612f23fc45124481dc2072e7e334b5daea4b8b18f7e13"}
{"private":"c8eb48f4d7b8939486d1bc5ab1fe276136fe96215349a509431d2ec134f75b83","public":"4b6c6f27c1e0031a0abe090ee05476d1caaa82e87ec49524f4ca392db7e6014bb0f79442c8705dd5fe97965b18778dc286bec540f5a5932469b1d423f30c4fb1"}
{"private":"5d5f63afeb89848fe9241e619f874447201f1e46686cd2f29c0fc3ac0cc59a94","public":"3bcaa1cadd5112c20fab8c9070bb4e0e474a1725adb0d6b135c0be00632e287ea338e43bc3bc7c50c054f8fe5cba29da3c5c2d836d6aa14eedf20df5657920de"}
```

Use the following commands in order to generate a buyer account, in which after the --key input you insert the public key of the pair so you can run this command:
```
flow accounts create --key f691abdb945ac166fbe5f1a06e3ebe6eaa77061099a796175efcdf661b6c76491ba116420fb51ae3f52c973474f96f25f88c57812ed95f4df1add3cf6fd89f1c --signer emulator-account
```

in the terminal you can check on the output the new created account address, so now using the private key and the address add this to the flow.json file under the "accounts" segment: 
```
"buyer-account": {
    "address": "01cf0e2f2f715450",
    "key": "3bc524119d2571a4b5691ca695ae5061bda8f4c7302371bc5c3f7d86ecbee4d4"
},
```

then repeat the same for seller-account, dapper-account and rcrdshp-account
```
flow accounts create --key fbbbbec5eeff5b669f08fd7be22d51dd855afc500cccff6a0274b1075d2bb2c6f53a2ef3d512fc7c339612f23fc45124481dc2072e7e334b5daea4b8b18f7e13 --signer emulator-account
flow accounts create --key 4b6c6f27c1e0031a0abe090ee05476d1caaa82e87ec49524f4ca392db7e6014bb0f79442c8705dd5fe97965b18778dc286bec540f5a5932469b1d423f30c4fb1 --signer emulator-account
flow accounts create --key 3bcaa1cadd5112c20fab8c9070bb4e0e474a1725adb0d6b135c0be00632e287ea338e43bc3bc7c50c054f8fe5cba29da3c5c2d836d6aa14eedf20df5657920de --signer emulator-account
```

and add under accounts the following outputs: 

```
"accounts": {
    "emulator-account": {
      "address": "f8d6e0586b0a20c7",
      "key": "a2c44ba71cf0629ab8f11c142a1566cd9eebb112611ca48600776a2096849ca6"
    },
    "buyer-account": {
      "address": "01cf0e2f2f715450",
      "key": "3bc524119d2571a4b5691ca695ae5061bda8f4c7302371bc5c3f7d86ecbee4d4"
    },
    "seller-account": {
      "address": "0x179b6b1cb6755e31",
      "key": "5edefdd0317d3a11acf9004554cfd1730e066623506325ae4016ea0eecb4bddd"
    },
    "dapper-account": {
      "address": "0xf3fcd2c1a78f5eee",
      "key": "c8eb48f4d7b8939486d1bc5ab1fe276136fe96215349a509431d2ec134f75b83"
    },
    "rcrdshp-account": {
      "address": "0xe03daebed8ca0615",
      "key": "5d5f63afeb89848fe9241e619f874447201f1e46686cd2f29c0fc3ac0cc59a94"
    }
},
```

### 3. We deploy the RCRDHSP contract into the rcrdshp account
In order to deploy the contract to the RCRDSHP account we need to update the flow.json file and add the following piece of code under CONTRACTS:

```
  "RCRDSHPNFT": {
    "source": "./cadence/contracts/RCRDSHPNFT.cdc",
    "aliases": {
      "emulator": "e03daebed8ca0615"
    }
  }
```

then we need to add this to the end of the file so it looks like this: 

```
"deployments": {
    "emulator": {
      "emulator-account": [
        "NonFungibleToken",
        "MetadataViews",
        "NFTStorefront",
        "DapperUtilityCoin"
      ],
      "rcrdshp-account": [
        "RCRDSHPNFT"
      ]
    }
}
```

and finally we update the project in order for the contract to be deployed to the account, dont forget to add the --update flag so it doesnt redeploy the contracts that are already there
```
flow project deploy --network emulator --update
```

### 4. Setup the accounts for RCRDSHPNFT
In order to set up all the accounts we need to run the transaction called initialize-account-emulator.cdc only on the buyer and seller account.
The rcrdshp account houls the contract to is already configured and the dapper account only pays for the nfts and it does not hold them.

```
flow transactions send ./initialize-account-emulator.cdc --signer seller-account --network emulator
flow transactions send ./initialize-account-emulator.cdc --signer buyer-account --network emulator
```
the terminal outputs for each of these commands contains no Events. 

### 5. Configure the needed account in order to receive DUC
The dapper account needs to hold and pay using DUC and the RCRDSHP account needs to receive the DUC paid by the dapper account so both accounts needs to be configured.
Also the seller needs to have DUC capability.

```
flow transactions send ./cadence/transactions/setupDUCAccount.cdc --signer dapper-account --network emulator
flow transactions send ./cadence/transactions/setupDUCAccount.cdc --signer rcrdshp-account --network emulator
flow transactions send ./cadence/transactions/setupDUCAccount.cdc --signer seller-account --network emulator
```

The terminal output doesnt show any events in this case

### 6. Configure seller-account and rcrdshp-account with a DUC forwarder
Because DUC is just a way to log into an event the movement of money and it does not have a per se utility, all the accounts that need to receive DUC 
also need to have a DUC forwarder in order to return the DUC back to the dapper account.  

In order to configure the forwarder to those accounts we need to run the following transactions: 
```
flow transactions send ./cadence/transactions/createDUCForwarder.cdc --signer rcrdshp-account --network emulator 0xf3fcd2c1a78f5eee
flow transactions send ./cadence/transactions/createDUCForwarder.cdc --signer seller-account --network emulator 0xf3fcd2c1a78f5eee
```

### 7. Mint some  DUC
Now we need to mint some DUC in order for the dapper account to be able to pay for any NFT

```
flow transactions send ./cadence/transactions/transferDUCToWallet.cdc --signer emulator-account --network emulator 0xf3fcd2c1a78f5eee 99999999.9
```


## USE CASE: Create nft, put it for sale and purchase from listing

### 1. Mint some NFTs
We need at least one NFT before putting for sale and the dapper account needs to have some DUC minted in order to pay for it on behalf of the buyer.
In order to mint an NFT we need to run this command and sign it with rcrdshp-account

```
flow transactions send ./cadence/transactions/mint_nft.cdc --signer rcrdshp-account --network emulator 0x179b6b1cb6755e31 '{"type":"Card","name":"Pristine Potty","rarity":"common","subtitle":"Festival Life","collectible_id":"ac7235ff-2f58-4213-9de5-2fd4ff36995f","description":"This Potty used to give ravers bad trips. Now you can align your chakras simply by sitting on the seat.","serial_number":"93","uri":"https://app.rcrdshp.com/collectibles/ac7235ff-2f58-4213-9de5-2fd4ff36995f"}'
```
So the deposit event shows the following:
```
Events:          
    Index       0
    Type        A.e03daebed8ca0615.RCRDSHPNFT.Deposit
    Tx ID       54d843583d7cc905b5893787eb01bfc896471d9ef870039bde085b638308dbdf
    Values
                - id (UInt64): 0 
                - to (Address?): 0x179b6b1cb6755e31 
```
Which means that the nft id 0 was minted and deposited to the address 0x179b6b1cb6755e31, which corresponds to the seller-account.

### 2. List the NFT for sale using the storefront
The NFT created in the step before corresponds to a Card, which means we need to use the "create-listing-rcrdshp-card-emulator.cdc" transaction for this purpose. 

```
flow transactions send ./create-listing-rcrdshp-card-emulator.cdc --signer seller-account 0 100.0
```

which yields the following output events: 

```
Events:          
    Index       0
    Type        A.f8d6e0586b0a20c7.NFTStorefront.StorefrontInitialized
    Tx ID       b5ce198c9f10ab88e37f8b45b0807413d5708eee8307120d5addafc132283a00
    Values
                - storefrontResourceID (UInt64): 48 

    Index       1
    Type        A.f8d6e0586b0a20c7.NFTStorefront.ListingAvailable
    Tx ID       b5ce198c9f10ab88e37f8b45b0807413d5708eee8307120d5addafc132283a00
    Values
                - storefrontAddress (Address): 0x179b6b1cb6755e31 
                - listingResourceID (UInt64): 49 
                - nftType (Type): Type<A.e03daebed8ca0615.RCRDSHPNFT.NFT>() 
                - nftID (UInt64): 0 
                - ftVaultType (Type): Type<A.f8d6e0586b0a20c7.DapperUtilityCoin.Vault>() 
                - price (UFix64): 100.00000000 
```
This means that the storefront was successfully configured on the seller account (storefrontResourceID (UInt64): 48) and
the nft with the id 0 was successfully put for sale (listingResourceID (UInt64): 49) 

### 3. Buyer buys the nft from the storefront
In order to buy from the storefront we need to use the purchase-nft-rcrdshp-emulator.cdc transaction.
Also because the nft is paid in DUC, a second signature is needed in order to authorize this transaction, so both dapper-account and the buyer-account are included in
the signature chain.

For this example we send a transaction with a lower price than expected in order to test that it should fail. 
```
> flow transactions build ./purchase-nft-rcrdshp-emulator.cdc 49 0x179b6b1cb6755e31 99.0 \
--proposer emulator-account    \
--payer emulator-account    \
--authorizer dapper-account \
--authorizer buyer-account  \
--filter payload --save unsigned_tx1 -y

> flow transactions sign unsigned_tx1 --signer dapper-account --filter payload --save signed_tx2 -y

> flow transactions sign signed_tx2 --signer buyer-account --filter payload --save signed_tx3 -y

> flow transactions sign signed_tx3 --signer emulator-account --filter payload --save signed_tx4 -y

> flow transactions send-signed signed_tx4 -y
```

So the transaction fails as expected!!! 
 ```
  % flow transactions send-signed signed_tx4 -y

❌ Transaction Error 
execution error code 1101: [Error Code: 1101] cadence runtime error Execution failed:
error: pre-condition failed: unexpected price
  --> 08cdfffcc69c361f0119800588bd99c5e0a79220abd570e20b0ef65abf247800:56:8
   |
56 |         self.salePrice == expectedPrice: "unexpected price"
   |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 ```


Now we can launch the transaction with the proper parameters in order to expect to succeed.

Check on the price in the following transaction, now is 100.0 DUC

```
> flow transactions build ./purchase-nft-rcrdshp-emulator.cdc 49 0x179b6b1cb6755e31 100.0 \
--proposer emulator-account    \
--payer emulator-account    \
--authorizer dapper-account \
--authorizer buyer-account  \
--filter payload --save unsigned_tx1 -y

> flow transactions sign unsigned_tx1 --signer dapper-account --filter payload --save signed_tx2 -y

> flow transactions sign signed_tx2 --signer buyer-account --filter payload --save signed_tx3 -y

> flow transactions sign signed_tx3 --signer emulator-account --filter payload --save signed_tx4 -y

> flow transactions send-signed signed_tx4 -y
```

This is the events generated at the output of the successful transaction!

```
Events:          
    Index       0
    Type        A.f8d6e0586b0a20c7.DapperUtilityCoin.TokensWithdrawn
    Tx ID       730aa3c7c351fbada6089eb0808a885e55eedd9ce7e5b032c9685dc1690ca120
    Values
                - amount (UFix64): 100.00000000 
                - from (Address?): 0xf3fcd2c1a78f5eee 

    Index       1
    Type        A.e03daebed8ca0615.RCRDSHPNFT.Withdraw
    Tx ID       730aa3c7c351fbada6089eb0808a885e55eedd9ce7e5b032c9685dc1690ca120
    Values
                - id (UInt64): 0 
                - from (Address?): 0x179b6b1cb6755e31 

    Index       2
    Type        A.f8d6e0586b0a20c7.DapperUtilityCoin.TokensWithdrawn
    Tx ID       730aa3c7c351fbada6089eb0808a885e55eedd9ce7e5b032c9685dc1690ca120
    Values
                - amount (UFix64): 87.50000000 
                - from (Never?): nil 

    Index       3
    Type        A.f8d6e0586b0a20c7.DapperUtilityCoin.TokensDeposited
    Tx ID       730aa3c7c351fbada6089eb0808a885e55eedd9ce7e5b032c9685dc1690ca120
    Values
                - amount (UFix64): 87.50000000 
                - to (Address?): 0xf3fcd2c1a78f5eee 

    Index       4
    Type        A.f8d6e0586b0a20c7.TokenForwarding.ForwardedDeposit
    Tx ID       730aa3c7c351fbada6089eb0808a885e55eedd9ce7e5b032c9685dc1690ca120
    Values
                - amount (UFix64): 87.50000000 
                - from (Address?): 0x179b6b1cb6755e31 

    Index       5
    Type        A.f8d6e0586b0a20c7.DapperUtilityCoin.TokensWithdrawn
    Tx ID       730aa3c7c351fbada6089eb0808a885e55eedd9ce7e5b032c9685dc1690ca120
    Values
                - amount (UFix64): 12.50000000 
                - from (Never?): nil 

    Index       6
    Type        A.f8d6e0586b0a20c7.DapperUtilityCoin.TokensDeposited
    Tx ID       730aa3c7c351fbada6089eb0808a885e55eedd9ce7e5b032c9685dc1690ca120
    Values
                - amount (UFix64): 12.50000000 
                - to (Address?): 0xf3fcd2c1a78f5eee 

    Index       7
    Type        A.f8d6e0586b0a20c7.TokenForwarding.ForwardedDeposit
    Tx ID       730aa3c7c351fbada6089eb0808a885e55eedd9ce7e5b032c9685dc1690ca120
    Values
                - amount (UFix64): 12.50000000 
                - from (Address?): 0xe03daebed8ca0615 

    Index       8
    Type        A.f8d6e0586b0a20c7.DapperUtilityCoin.TokensDeposited
    Tx ID       730aa3c7c351fbada6089eb0808a885e55eedd9ce7e5b032c9685dc1690ca120
    Values
                - amount (UFix64): 0.00000000 
                - to (Address?): 0xf3fcd2c1a78f5eee 

    Index       9
    Type        A.f8d6e0586b0a20c7.TokenForwarding.ForwardedDeposit
    Tx ID       730aa3c7c351fbada6089eb0808a885e55eedd9ce7e5b032c9685dc1690ca120
    Values
                - amount (UFix64): 0.00000000 
                - from (Address?): 0x179b6b1cb6755e31 

    Index       10
    Type        A.f8d6e0586b0a20c7.NFTStorefront.ListingCompleted
    Tx ID       730aa3c7c351fbada6089eb0808a885e55eedd9ce7e5b032c9685dc1690ca120
    Values
                - listingResourceID (UInt64): 49 
                - storefrontResourceID (UInt64): 48 
                - purchased (Bool): true 

    Index       11
    Type        A.e03daebed8ca0615.RCRDSHPNFT.Deposit
    Tx ID       730aa3c7c351fbada6089eb0808a885e55eedd9ce7e5b032c9685dc1690ca120
    Values
                - id (UInt64): 0 
                - to (Address?): 0x1cf0e2f2f715450
```


## USE CASE: List NFT for sale, then delist
We need to mint a new nft into the seller account

```
flow transactions send ./cadence/transactions/mint_nft.cdc --signer rcrdshp-account --network emulator 0x179b6b1cb6755e31 '{"type":"Card","name":"Pristine Potty","rarity":"common","subtitle":"Festival Life","collectible_id":"ac7235ff-2f58-4213-9de5-2fd4ff36995f","description":"This Potty used to give ravers bad trips. Now you can align your chakras simply by sitting on the seat.","serial_number":"93","uri":"https://app.rcrdshp.com/collectibles/ac7235ff-2f58-4213-9de5-2fd4ff36995f"}'
```

Now we have nft id 1 inside our seller-account: 

```
Events:          
    Index       0
    Type        A.e03daebed8ca0615.RCRDSHPNFT.Deposit
    Tx ID       d921c5a1456023369c04d0907d6b078d12fb9d2eb1e99245100f2cc075a8c930
    Values
                - id (UInt64): 1 
                - to (Address?): 0x179b6b1cb6755e31
```

the next step is to list it for sale: 

```
flow transactions send ./create-listing-rcrdshp-card-emulator.cdc --signer seller-account 1 100.0
```

Here is the log showing the successful listing: 

```
Events:          
    Index       0
    Type        A.f8d6e0586b0a20c7.NFTStorefront.ListingAvailable
    Tx ID       ca4463dda9da739e09de21314fd4b7b973de14f66751b4abbdd08f740e08a220
    Values
                - storefrontAddress (Address): 0x179b6b1cb6755e31 
                - listingResourceID (UInt64): 56 
                - nftType (Type): Type<A.e03daebed8ca0615.RCRDSHPNFT.NFT>() 
                - nftID (UInt64): 1 
                - ftVaultType (Type): Type<A.f8d6e0586b0a20c7.DapperUtilityCoin.Vault>() 
                - price (UFix64): 100.00000000 
```

Now we delist it using the listingResourceID as input

```
flow transactions send ./remove-listing-emulator.cdc --signer seller-account 56
```

we get the following output: 

```
Events:          
    Index       0
    Type        A.f8d6e0586b0a20c7.NFTStorefront.ListingCompleted
    Tx ID       3e6998396dacf93c24ef285d1849fcb4d46305a608d7b2710b8919818f7093e9
    Values
                - listingResourceID (UInt64): 56 
                - storefrontResourceID (UInt64): 48 
                - purchased (Bool): false 
```

## USE CASE: Read the list of NFTS from an account
In order to do this we need to run a script and to use the account address as argument so we run: 

SELLER ACCOUNT
```
flow scripts execute ./cadence/scripts/checkNFTList.cdc 0x01cf0e2f2f715450 
```
And the output is this:

```
Result: [0]
```

BUYER ACCOUNT
```
flow scripts execute ./cadence/scripts/checkNFTList.cdc 0x179b6b1cb6755e31 
```
And the output is this: 

```
Result: [1]
```

## USE CASE: Read the list of storefront listings and corresponding details

We need to create a listing first, then we read the ids and by using this ID we can get the details of the listing
```
flow transactions send ./create-listing-rcrdshp-card-emulator.cdc --signer seller-account 1 100.0
```
the output is the following: 

```
Events:          
    Index       0
    Type        A.f8d6e0586b0a20c7.NFTStorefront.ListingAvailable
    Tx ID       655c6df56b1de1999a1f1593350efbff1b18a0402de1626857d7600048eaad72
    Values
                - storefrontAddress (Address): 0x179b6b1cb6755e31 
                - listingResourceID (UInt64): 57 
                - nftType (Type): Type<A.e03daebed8ca0615.RCRDSHPNFT.NFT>() 
                - nftID (UInt64): 1 
                - ftVaultType (Type): Type<A.f8d6e0586b0a20c7.DapperUtilityCoin.Vault>() 
                - price (UFix64): 100.00000000 
```

now we get all the listing ids from the account: 

```
flow scripts execute ./cadence/scripts/readStorefrontIds.cdc 0x179b6b1cb6755e31
```
The output is returning all the ids for that address, which in this case it should only be one: 

```
Result: [57]
```

now we get the details of the listing: 

```
flow scripts execute ./cadence/scripts/readListingDetails.cdc 0x179b6b1cb6755e31 57
```

And the output: 

```
Result: A.f8d6e0586b0a20c7.NFTStorefront.ListingDetails(storefrontID: 48, purchased: false, nftType: Type<A.e03daebed8ca0615.RCRDSHPNFT.NFT>(), nftID: 1, salePaymentVaultType: Type<A.f8d6e0586b0a20c7.DapperUtilityCoin.Vault>(), salePrice: 100.00000000, saleCuts: [A.f8d6e0586b0a20c7.NFTStorefront.SaleCut(receiver: Capability<&AnyResource{A.ee82856bf20e2aa6.FungibleToken.Receiver}>(address: 0x179b6b1cb6755e31, path: /public/dapperUtilityCoinReceiver), amount: 87.50000000), A.f8d6e0586b0a20c7.NFTStorefront.SaleCut(receiver: Capability<&AnyResource{A.ee82856bf20e2aa6.FungibleToken.Receiver}>(address: 0xe03daebed8ca0615, path: /public/dapperUtilityCoinReceiver), amount: 12.50000000)])
```
