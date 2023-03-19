// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Vault} from "./Vault.sol";
import {Dyad} from "./Dyad.sol";
import {DNft} from "./DNft.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

contract VaultFactory {
  using Clones for address;

  event Deployed(address dNft, address dyad);

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
      address _oracle,
      string memory _collateralSymbol 
  ) public 
    returns (
      address,
      address
    ) {
      if (deployed[_collateral][_oracle]) revert AlreadyDeployed();

      Dyad dyad = Dyad(dyadImpl.clone());

      dyad.initialize(
        string.concat(_collateralSymbol, "DYAD-"),
        string.concat("d", _collateralSymbol)
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
