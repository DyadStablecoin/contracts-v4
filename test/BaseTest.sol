// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {DeployBase} from "../script/deploy/DeployBase.s.sol";
import {DNft} from "../src/core/DNft.sol";
import {Dyad} from "../src/core/Dyad.sol";
import {OracleMock} from "./OracleMock.sol";
import {ZoraMock} from "./ZoraMock.sol";
import {Parameters} from "../src/Parameters.sol";
import {Vault} from "../src/core/Vault.sol";
import {VaultFactory} from "../src/core/VaultFactory.sol";

contract BaseTest is Test, Parameters {
  using stdStorage for StdStorage;

  DNft         dNft;
  Dyad         dyad;
  Vault        vault;
  VaultFactory factory;
  OracleMock   oracleMock;
  ZoraMock     zoraMock;
  ERC20        collat;

  receive() external payable {}

  function setUp() public {
    oracleMock = new OracleMock();
    zoraMock   = new ZoraMock();
    DeployBase deployBase = new DeployBase();
    (
      address _dNft,
      address _dyad,
      address _vault, 
      address _factory, 
      address _zora
    ) = deployBase.deploy(
      MAINNET_OWNER,
      MAINNET_WETH,
      MAINNET_WETH_SYMBOL, 
      address(oracleMock)
    );
    dNft     = DNft(_dNft);
    dyad     = Dyad(_dyad);
    vault    = Vault(_vault);
    collat   = ERC20(MAINNET_WETH);
    factory  = VaultFactory(_factory);
    zoraMock = ZoraMock(_zora);
    vm.warp(block.timestamp + 1 days);

    deal(MAINNET_WETH, address(this), 1e18 ether);
    zoraMock.safeMint(address(this), 0);
  }

  function overwrite(
    address _contract,
    string memory signature,
    uint value
  ) public {
    stdstore.target(_contract).sig(signature).checked_write(value); 
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure returns (bytes4) {
    return 0x150b7a02;
  }
}
