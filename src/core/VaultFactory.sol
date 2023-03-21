// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {Vault} from "./Vault.sol";
import {Dyad} from "./Dyad.sol";
import {DNft} from "./DNft.sol";
import {IVaultFactory} from "../interfaces/IVaultFactory.sol";

contract VaultFactory is IVaultFactory {
  using Clones for address;

  DNft    public immutable dNft;
  address public immutable vaultImpl;
  address public immutable dyadImpl;

  // collateral => oracle => deployed
  mapping(address => mapping(address => bool)) public vaults;

  constructor(
    address _dNft,
    address _vaultImpl, 
    address _dyadImpl
  ) { 
    dNft      = DNft(_dNft); 
    vaultImpl = _vaultImpl;
    dyadImpl  = _dyadImpl;
  }

  /// @inheritdoc IVaultFactory
  function deploy(
      address collateral, 
      address oracle
  ) external 
    returns (
      address,
      address
    ) {
      if (collateral == address(0))   revert InvalidCollateral();
      if (oracle     == address(0))   revert InvalidOracle();
      if (collateral == oracle)       revert CollateralEqualsOracle();
      if (vaults[collateral][oracle]) revert AlreadyDeployed();

      // `symbol` is not officially part of the ERC20 standard!
      string memory collateralSymbol = ERC20(collateral).symbol(); 
      if (bytes(collateralSymbol).length == 0) revert InvalidCollateral();

      Dyad dyad = Dyad(dyadImpl.clone());
      dyad.initialize(
        string.concat(collateralSymbol, "DYAD-"),
        string.concat("d", collateralSymbol)
      );

      Vault vault = Vault(vaultImpl.clone());
      vault.initialize(
        address(dNft), 
        address(dyad),
        collateral,
        oracle
      );

      dNft.addLiquidator(address(vault)); 
      dyad.setOwner     (address(vault));
      vaults[collateral][oracle] = true;
      emit Deploy(address(vault), address(dyad));
      return (address(vault), address(dyad));
  }
}
