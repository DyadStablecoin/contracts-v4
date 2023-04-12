// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {BaseTest} from "./BaseTest.sol";

contract VaultTest is BaseTest {
  function deposit(uint id, uint amount) public {
    collat.approve(address(vault), amount);
    vault.deposit(id, amount);
  }
  // -------------------- deposit --------------------
  function test_deposit() public {
    uint id = dNft.mintNft(0, address(this));
    assertEq(vault.id2collat(id), 0 ether);
    deposit(id, 10 ether);
    assertEq(vault.id2collat(id), 10 ether);
  }

  // -------------------- withdraw --------------------
  function test_withdraw() public {
    uint id = dNft.mintNft(0, address(this));
    deposit(id, 1 ether);
    vault.withdraw(id, address(this), 1 ether);
  }
  function testCannot_withdraw_notNftOwner() public {
    uint id = dNft.mintNft(0, address(this));
    deposit(id, 1 ether);
    vm.prank(address(1));
    vm.expectRevert();
    vault.withdraw(id, address(this), 1 ether);
  }
  function testCannot_withdraw_moreThanCollateral() public {
    uint id = dNft.mintNft(0, address(this));
    deposit(id, 1 ether);
    vm.expectRevert();
    vault.withdraw(id, address(this), 2 ether);
  }
  function testCannot_withdraw_moreThanCollateralRatio() public {
    uint id = dNft.mintNft(0, address(this));
    deposit(id, 1 ether);
    vault.mintDyad(id, address(this), 300 ether);
    vm.expectRevert();
    vault.withdraw(id, address(this), 0.3 ether);
  }

  // -------------------- mintDyad --------------------
  function test_mintDyad() public {
    uint id = dNft.mintNft(0, address(this));
    deposit(id, 1 ether);
    vault.mintDyad(id, address(this), 300 ether);
  }
  function testCannot_mintDyad_notNftOwner() public {
    uint id = dNft.mintNft(0, address(this));
    deposit(id, 1 ether);
    vm.prank(address(1));
    vm.expectRevert();
    vault.mintDyad(id, address(this), 300 ether);
  }
  function testCannot_mintDyad_moreThanCollateralRatio() public {
    uint id = dNft.mintNft(0, address(this));
    deposit(id, 1 ether);
    vm.expectRevert();
    vault.mintDyad(id, address(this), 400 ether);
  }

  // -------------------- liquidate --------------------
  function test_liquidate() public {
    uint id = dNft.mintNft(0, address(this));
    deposit(id, 1 ether);
    vault.mintDyad(id, address(this), 300 ether);
    oracleMock.setPrice(100e8);
    uint collatBefore = vault.id2collat(id);
    collat.approve(address(vault), 10 ether);
    vault.liquidate(id, address(1), 10 ether);
    assertTrue(collatBefore < vault.id2collat(id));
  }
  function testCannot_liquidate_CrTooHigh() public {
    uint id = dNft.mintNft(0, address(this));
    deposit(id, 1 ether);
    vm.expectRevert();
    vault.liquidate(id, address(1), 10 ether);
  }
  function testCannot_liquidate_CrTooLow() public {
    uint id = dNft.mintNft(0, address(this));
    deposit(id, 1 ether);
    vault.mintDyad(id, address(this), 300 ether);
    oracleMock.setPrice(100e8);
    vm.expectRevert();
    vault.liquidate(id, address(1), 1 ether);
  }

  // -------------------- redeem --------------------
  function test_redeem() public {
    uint id = dNft.mintNft(0, address(this));
    deposit(id, 1 ether);
    vault.mintDyad(id, address(this), 300 ether);
    assertEq(dyad.balanceOf(address(this)), 300 ether);
    uint collatBefore = address(this).balance;
    uint collatVaultBefore = vault.id2collat(id);
    assertEq(dyad.balanceOf(address(this)), 300 ether);
    assertEq(vault.id2dyad(id), 300 ether);
    vault.redeem(id, address(this), 300 ether);
    assertEq(dyad.balanceOf(address(this)), 0 ether);
    assertTrue(collatBefore < collat.balanceOf(address(this)));
    assertTrue(collatVaultBefore > vault.id2collat(id));
    assertEq(dyad.balanceOf(address(this)), 0);
    assertEq(vault.id2dyad(id), 0);
  }
  function testCannot_redeem_notNftOwner() public {
    uint id = dNft.mintNft(0, address(this));
    deposit(id, 1 ether);
    vault.mintDyad(id, address(this), 300 ether);
    vm.prank(address(1));
    vm.expectRevert();
    vault.redeem(id, address(this), 300 ether);
  }
  function testCannot_redeem_moreThanWithdrawn() public {
    uint id = dNft.mintNft(0, address(this));
    deposit(id, 1 ether);
    vault.mintDyad(id, address(this), 300 ether);
    vm.expectRevert();
    vault.redeem(id, address(this), 400 ether);
  }
}
