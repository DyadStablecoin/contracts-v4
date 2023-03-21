// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {BaseTest} from "./BaseTest.sol";

contract VaultFactoryTest is BaseTest {
  function test_correctDeployment() public {
    assertTrue(factory.vaults(MAINNET_WETH, MAINNET_ORACLE));
  }
  function test_fail_deploySameVaultAgain() public {
    vm.expectRevert();
    factory.deploy(MAINNET_WETH, MAINNET_ORACLE);
  }
}
