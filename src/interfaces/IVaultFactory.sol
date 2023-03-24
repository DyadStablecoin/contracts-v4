// SPDX-License-Identifier: MIT
pragma solidity = 0.8.17;

interface IVaultFactory {
  event Deploy(address indexed vault);

  error InvalidCollateral();
  error InvalidOracle();
  error CollateralEqualsOracle();
  error AlreadyDeployed();

  /**
   * @notice Deploy a new Vault and its corresponding DYAD type
   * @dev Will revert:
   *      - If `collateral` is the zero address
   *      - If `oracle` is the zero address
   *      - If `collateral` `oracle` pair has already been deployed
   * @dev Emits:
   *      - Deploy(address indexed vault, address indexed dyad)
   * @param collat Address of the ERC-20 token to use as collateral
   * @param collatSymbol     Symbol of the ERC-20 token to use as collateral
   * @param collatOracle     Address of the Oracle to use
   * @return vault     Address of the deployed Vault
   */
  function deploy(
    address       collat,
    string memory collatSymbol,
    address       collatOracle
  ) external 
    returns (address);
}
