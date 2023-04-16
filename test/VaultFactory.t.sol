// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {BaseTest} from "./BaseTest.sol";

contract VaultFactoryTest is BaseTest {
  function test_correctDeployment() public {
    assertTrue(factory.vaults(MAINNET_WETH, address(oracleMock)) != address(0));
    assertTrue(address(vault.dNft())   != address(0));
    assertTrue(address(vault.collat()) != address(0));
    assertTrue(address(vault.oracle()) != address(0));

    assertTrue(bytes(vault.dyad().symbol()).length > 0);
    assertTrue(bytes(vault.dyad().name())  .length > 0);
    assertTrue(vault.dyad().owner()    == address(vault));
  }
  function test_fail_deployWithWrongOracle() public {
    vm.expectRevert();
    factory.deploy(MAINNET_WETH, MAINNET_WETH_SYMBOL, address(0));
  }
  function test_fail_deployWithWrongCollateral() public {
    vm.expectRevert();
    factory.deploy(address(0), MAINNET_WETH_SYMBOL, MAINNET_ORACLE);
  }
  function test_fail_deployWithSameOracleAndCollateral() public {
    vm.expectRevert();
    factory.deploy(MAINNET_WETH, MAINNET_WETH_SYMBOL, MAINNET_WETH);
  }
  function test_fail_deploySameVaultAgain() public {
    vm.expectRevert();
    factory.deploy(MAINNET_WETH, MAINNET_WETH_SYMBOL, MAINNET_WETH);
  }
}
