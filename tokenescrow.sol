//
// A contract for running an escrow service for Ethereum token-contracts
//
// Supports the "standardized token API" as described in https://github.com/ethereum/wiki/wiki/Standardized_Contract_APIs
//
// To create an escrow request, follow these steps:
// 1. Call the create() method for setup
// 2. Transfer the tokens to the escrow contract
//
// The recipient can make a simple Ether transfer to get the tokens released to his address.
//
// The buyer pays all the fees (including gas).
//

contract IToken {
  function balanceOf(address _address) constant returns (uint balance);
  function transfer(address _to, uint _value) returns (bool success);
}

contract TokenEscrow {
  address owner;
  modifier owneronly { if (msg.sender == owner) _ }
  function setOwner(address _owner) owneronly {
    owner = _owner;
  }

  function TokenEscrow() {
    owner = msg.sender;
  }

  struct Escrow {
    address token;           // address of the token contract
    uint tokenAmount;        // number of tokens requested
    bool tokenReceived;      // are tokens received?
    uint price;              // price to be paid by buyer
    address seller;          // seller's address
    address recipient;       // address to receive the tokens
  }

  mapping (address => Escrow) public escrows;

  function create(address token, uint tokenAmount, uint price, address seller, address buyer, address recipient) {
    escrows[buyer] = Escrow(token, tokenAmount, false, price, seller, recipient);
  }

  function create(address token, uint tokenAmount, uint price, address seller, address buyer) {
     create(token, tokenAmount, price, seller, buyer, buyer);
  }

  // Incoming transfer from the buyer
  function() {
    Escrow escrow = escrows[msg.sender];

    // Contract not set up
    if (escrow.token == 0)
      throw;

    IToken token = IToken(escrow.token);

    // Check the token contract if we have been issued tokens already
    if (!escrow.tokenReceived) {
      uint balance = token.balanceOf(this);
      if (balance >= escrow.tokenAmount)
        escrow.tokenReceived = true;
      // FIXME: what to do if we've received more tokens than required?
    }

    // No tokens yet
    if (!escrow.tokenReceived)
      throw;

    // Buyer's price is below the agreed
    if (msg.value < escrow.price)
      throw;

    // Transfer tokens to buyer
    token.transfer(escrow.recipient, escrow.tokenAmount);

    // Transfer money to seller
    escrow.seller.send(escrow.price);

    // Refund buyer if overpaid
    msg.sender.send(escrow.price - msg.value);

    delete escrows[msg.sender];
  }

  function kill() owneronly {
    suicide(msg.sender);
  }
}
