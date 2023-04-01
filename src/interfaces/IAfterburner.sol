// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IAfterburner {

  /**
   * @notice Deposit `amount` of a DYAD from a specific `vault` into Afterburner
   */
  function deposit(uint tokenId, address vault, uint amount) external;

  function mint(uint tokenId, address vault, uint amount, address recipient) external;
}
