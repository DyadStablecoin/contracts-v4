// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/Script.sol";
import {Dyad} from "../../src/core/Dyad.sol";
import {DNft} from "../../src/core/DNft.sol";
import {IDNft} from "../../src/interfaces/IDNft.sol";
import {Parameters} from "../../src/Parameters.sol";
import {DNft} from "../../src/core/DNft.sol";
import {Factory} from "../../src/core/Factory.sol";

contract DeployBase is Script, Parameters {
  function deploy(
    address _collateral,
    address _oracle,
    string memory _flavor
  )
    public 
    payable 
    returns (address, address, address) {
      vm.startBroadcast();

      DNft dNft = new DNft();
      Factory factory = new Factory(address(dNft));
      dNft.transferOwnership(address(factory));

      (address vault, address dyad) = factory.deploy(
        _collateral,
        _oracle,
        _flavor
      );

      vm.stopBroadcast();
      return (address(dNft), address(dyad), address(vault));
  }
}
