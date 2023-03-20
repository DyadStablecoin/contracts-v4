// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Vault} from "./Vault.sol";
import {Dyad} from "./Dyad.sol";
import {DNft} from "./DNft.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VaultFactory {
  using Clones for address;

  event Deployed(address dNft, address dyad);

  error InvalidCollateral();
  error InvalidOracle();
  error InvalidCollateralSymbol();
  error AlreadyDeployed();

  address public immutable vaultImpl;
  address public immutable dyadImpl;

  // collateral => oracle => deployed
  mapping(address => mapping(address => bool)) public deployed;

  DNft public dNft;

  constructor(
    address _dNft,
    address _vaultImpl, 
    address _dyadImpl
  ) { 
    dNft      = DNft(_dNft); 
    vaultImpl = _vaultImpl;
    dyadImpl  = _dyadImpl;
  }

  function deploy(
      address _collateral, 
      address _oracle
  ) public 
    returns (
      address,
      address
    ) {
      if (_collateral == address(0))            revert InvalidCollateral();
      if (_oracle     == address(0))            revert InvalidOracle();
      if (deployed[_collateral][_oracle])       revert AlreadyDeployed();

      Dyad dyad = Dyad(dyadImpl.clone());

      // `symbol` is not officially part of the ERC20 standard!
      string memory collateralSymbol = ERC20(_collateral).symbol(); 

      dyad.initialize(
        string.concat(collateralSymbol, "DYAD-"),
        string.concat("d", collateralSymbol)
      );

      Vault vault = Vault(vaultImpl.clone());

      vault.initialize(
        address(dNft), 
        address(dyad),
        _collateral,
        _oracle
      );

      dNft.setLiquidator(address(vault)); 
      dyad.setOwner(address(vault));
      deployed[_collateral][_oracle] = true;
      emit Deployed(address(vault), address(dyad));
      return (address(vault), address(dyad));
  }
}
