// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {DeployBase} from "../script/deploy/DeployBase.s.sol";
import {DNft} from "../src/core/DNft.sol";
import {Dyad} from "../src/core/Dyad.sol";
import {OracleMock} from "./OracleMock.sol";
import {Parameters} from "../src/Parameters.sol";
import {Vault} from "../src/core/Vault.sol";
import {Factory} from "../src/core/Factory.sol";

contract BaseTest is Test, Parameters {
  using stdStorage for StdStorage;

  DNft    dNft;
  Dyad    dyad;
  Vault   vault;
  Factory factory;
  OracleMock oracleMock;

  receive() external payable {}

  function setUp() public {
    oracleMock = new OracleMock();
    DeployBase deployBase = new DeployBase();
    (
      address _dNft,
      address _dyad,
      address _vault, 
      address _factory
    ) = deployBase.deploy(
      MAINNET_OWNER,
      MAINNET_WETH,
      MAINNET_ORACLE,
      "ETH"
    );
    dNft    = DNft(_dNft);
    dyad    = Dyad(_dyad);
    vault   = Vault(_vault);
    factory = Factory(_factory);
    vm.warp(block.timestamp + 1 days);
  }

  function overwrite(address _contract, string memory signature, uint value) public {
    stdstore.target(_contract).sig(signature).checked_write(value); 
  }

  function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
    return 0x150b7a02;
  }
}
