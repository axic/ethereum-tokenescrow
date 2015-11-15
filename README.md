# TokenEscrow

A simple implementation of a smart contract handling an escrow transaction. The only case it supports is selling a token issued by other contracts for Ether.

The tokens must support the "standardized token API" as described in https://github.com/ethereum/wiki/wiki/Standardized_Contract_APIs - at least the balanceOf() and transfer() methods.

The aim is to reduce the complexity for the buyer, while still keeping the burden relatively low on the seller.

## How it works

To create an escrow request, follow these steps:
1. Call the create() method for setup
2. Transfer the tokens to the escrow contract

After this point, the recipient can make a simple Ether transfer to get the tokens released to his address. *The buyer pays all the fees (including gas).*

## Example usage

### Seller or Buyer or a third-party: Deploy the escrow smart contract

I do not have this deployed publicly. Follow the usual guides on how to deploy.

### Seller: Create an actual escrow contract

To create the contract, execute the following in the *Geth* console:

```js
var tokenEscrowABI = [{"constant":false,"inputs":[{"name":"token","type":"address"},{"name":"tokenAmount","type":"uint256"},{"name":"price","type":"uint256"},{"name":"seller","type":"address"},{"name":"buyer","type":"address"}],"name":"create","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"token","type":"address"},{"name":"tokenAmount","type":"uint256"},{"name":"price","type":"uint256"},{"name":"seller","type":"address"},{"name":"buyer","type":"address"},{"name":"recipient","type":"address"}],"name":"create","outputs":[],"type":"function"}]

var tokenEscrow = eth.contract(tokenEscrowABI).at("<address of the escrow contract>");

tokenEscrow.create(<token contract>, <number of tokens>, <price requested>, <seller address>, <buyer address>, <recipient address>, 10, { from: eth.accounts[0] });
```

The parameters are as follows:
* token: the contract address of the token to be transferred.
* number of tokens: expected number to be transferred. FIXME: Excess is retained by the escrow.
* price requested: the expected price in Ether. Excess is sent back.
* seller: the address of the seller (the Ether will be sent here).
* buyer: the address the payment will come from
* recipient: the address where the tokens will need to be transferred to.

### Seller: Transfer the tokens

Transfer the tokens by the usual means when interacting with tokens. You can also use the new *Ethereum-Wallet* (see the [reddit announcement](https://www.reddit.com/r/ethereum/comments/3rcnrx/ethereum_wallet_beta3_contract_deployment_and/)) to do it.

### Buyer: Transfer the Ethers

Transfer the Ethers via a plain old transaction. There is no fancy contract thing happening here. Well, one thing only: you have to cover the gas costs and this might require an increase of the default setting.

In *Geth* it is easy to do so:

```js
eth.sendTransaction({from: eth.accounts[0], value: web3.toWei(1, 'ether'), to: "<address of contract>", gas: 1000000})
```

In my experience though this is not needed.

## Contributing

I am more than happy to receive improvements. Please send me a pull request or reach out on email or twitter.

## License

    Copyright (C) 2015 Alex Beregszaszi

    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
