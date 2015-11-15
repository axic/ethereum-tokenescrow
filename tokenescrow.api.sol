contract TokenEscrow {
  function create(address token, uint tokenAmount, uint price, address seller, address buyer, address recipient);

  function create(address token, uint tokenAmount, uint price, address seller, address buyer);
}
