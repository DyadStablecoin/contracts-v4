// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Dyad} from "../../src/core/Dyad.sol";
import {DNft} from "../../src/core/DNft.sol";
import {IDNft} from "../../src/interfaces/IDNft.sol";
import {Parameters} from "../../src/Parameters.sol";
import {DNft} from "../../src/core/DNft.sol";
import {VaultFactory} from "../../src/core/VaultFactory.sol";
import {Vault} from "../../src/core/Vault.sol";
import {ZoraMock} from "../../test/ZoraMock.sol";

contract DeployBase is Script, Parameters {
  function deploy(
      address       _owner,
      address       _collat,
      string memory _collatSymbol, 
      address       _collatOracle
  )
    public 
    payable 
    returns (address, address, address, address, address) {
      vm.startBroadcast();

      ZoraMock     zora    = new ZoraMock();
      DNft         dNft    = new DNft(ERC721(zora));
      VaultFactory factory = new VaultFactory(dNft);
      dNft.setFactory(address(factory));
      dNft.transferOwnership(address(_owner));

      address vault = factory.deploy(
        _collat,
        _collatSymbol, 
        _collatOracle 
      );

      vm.stopBroadcast();
      return (
        address(dNft),
        address(Vault(vault).dyad()),
        address(vault),
        address(factory), 
        address(zora)
      );
  }
}
