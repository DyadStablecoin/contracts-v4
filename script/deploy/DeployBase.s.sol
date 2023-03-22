// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/Script.sol";
import {Dyad} from "../../src/core/Dyad.sol";
import {DNft} from "../../src/core/DNft.sol";
import {IDNft} from "../../src/interfaces/IDNft.sol";
import {Parameters} from "../../src/Parameters.sol";
import {DNft} from "../../src/core/DNft.sol";
import {VaultFactory} from "../../src/core/VaultFactory.sol";
import {Vault} from "../../src/core/Vault.sol";

contract DeployBase is Script, Parameters {
  function deploy(
      address _owner,
      address _collateral,
      address _oracle
  )
    public 
    payable 
    returns (address, address, address, address) {
      vm.startBroadcast();

      DNft         dNft    = new DNft();
      VaultFactory factory = new VaultFactory(address(dNft));
      dNft.setFactory(address(factory));
      dNft.transferOwnership(address(_owner));

      (address vault, address dyad) = factory.deploy(
        _collateral,
        _oracle
      );

      vm.stopBroadcast();
      return (address(dNft), address(dyad), address(vault), address(factory));
  }
}
