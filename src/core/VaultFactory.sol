// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {Vault} from "./Vault.sol";
import {Dyad} from "./Dyad.sol";
import {DNft} from "./DNft.sol";
import {IVaultFactory} from "../interfaces/IVaultFactory.sol";

contract VaultFactory is IVaultFactory {
  DNft public immutable dNft;

  // collateral => oracle => vault
  mapping(address => mapping(address => address)) public vaults;

  constructor(address _dNft) { dNft = DNft(_dNft); }

  /// @inheritdoc IVaultFactory
  function deploy(
      address collateral, 
      address oracle
  ) external 
    returns (
      address,
      address
    ) {
      if (collateral == address(0)) revert InvalidCollateral();
      if (oracle     == address(0)) revert InvalidOracle();
      if (collateral == oracle)     revert CollateralEqualsOracle();
      if (vaults[collateral][oracle] != address(0)) revert AlreadyDeployed();

      // `symbol` is not officially part of the ERC20 standard!
      string memory collateralSymbol = ERC20(collateral).symbol(); 
      if (bytes(collateralSymbol).length == 0) revert InvalidCollateral();

      Dyad dyad = new Dyad(
        string.concat(collateralSymbol, "DYAD-"),
        string.concat("d", collateralSymbol)
      );

      Vault vault = new Vault(
        address(dNft), 
        address(dyad),
        collateral,
        oracle
      );

      dNft.addLiquidator    (address(vault)); 
      dyad.transferOwnership(address(vault));
      vaults[collateral][oracle] = address(vault);
      emit Deploy(address(vault), address(dyad));
      return (address(vault), address(dyad));
  }
}
