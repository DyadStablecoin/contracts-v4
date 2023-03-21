// SPDX-License-Identifier: MIT
pragma solidity = 0.8.17;

interface IVaultFactory {
  event Deploy(address indexed vault, address indexed dyad);

  error InvalidCollateral();
  error InvalidOracle();
  error CollateralEqualsOracle();
  error AlreadyDeployed();
  error InvalidCollateralSymbol();

  /**
   * @notice Deploy a new Vault and its corresponding DYAD type
   * @dev Will revert:
   *      - If `collateral` is the zero address
   *      - If `oracle` is the zero address
   *      - If `collateral` `oracle` pair has already been deployed
   * @dev Emits:
   *      - Deploy(address indexed vault, address indexed dyad)
   * @param collateral Address of the ERC-20 token to use as collateral
   * @param oracle     Address of the Oracle to use
   * @return vault     Address of the deployed Vault
   * @return dyad      Address of the newly deployed DYAD type
   */
  function deploy(
    address collateral,
    address oracle
  ) external returns (
    address, 
    address
  );
}
