// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IAfterburner {

  event Minted  (uint indexed tokenId, address indexed vault, uint amount, address recipient);
  event Redeemed(uint indexed tokenId, address indexed vault, uint amount, address recipient);

  /**
   * @notice Deposit `amount` of a DYAD from a specific `vault` into Afterburner
   */
  function deposit(uint tokenId, address vault, uint amount) external;

  function mint(uint tokenId, address vault, uint amount, address recipient) external;

  function redeem(uint tokenId, address vault, uint amount, address recipient) external;
}
