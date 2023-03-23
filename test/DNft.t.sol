// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";
import {BaseTest} from "./BaseTest.sol";
import {Parameters} from "../src/Parameters.sol";
import {SharesMath} from "../src/libraries/SharesMath.sol";

contract DNftsTest is BaseTest {
  function test_constructor() public {
    assertEq(dNft.owner(),   MAINNET_OWNER);
    assertEq(dNft.factory(), address(factory));
  }

  // -------------------- mintNft --------------------
  function test_mintNft() public {
    dNft.mintNft{value: dNft.ETH_SACRIFICE()}(address(this));
  }
  function testCannot_mintNft_publicMintsExceeded() public {
    for(uint i = 0; i < dNft.PUBLIC_MINTS(); i++) {
      dNft.mintNft{value: dNft.ETH_SACRIFICE()}(address(this));
    }
    uint ethSacrifice = dNft.ETH_SACRIFICE();
    vm.expectRevert();
    dNft.mintNft{value: ethSacrifice}(address(this));
  }

  // -------------------- mintInsiderNft --------------------
  function test_mintInsiderNft() public {
    vm.prank(MAINNET_OWNER);
    dNft.mintNft{value: dNft.ETH_SACRIFICE()}(address(this));
  }
  function testCannot_mintInsiderNft_NotOwner() public {
    vm.expectRevert();
    dNft.mintInsiderNft(address(this));
  }
  function testCannot_mintInsiderNft_insiderMintsExceeded() public {
    for(uint i = 0; i < dNft.INSIDER_MINTS(); i++) {
      dNft.mintNft{value: dNft.ETH_SACRIFICE()}(address(this));
    }
    vm.expectRevert();
    dNft.mintInsiderNft(address(this));
  }

  // -------------------- addLiquidator --------------------
  function test_addLiquidator() public {
    vm.prank(address(factory));
    dNft.addLiquidator(address(this));
    assertTrue(dNft.isLiquidator(address(this)));
  }
  function test_fail_addLiquidator_notFactory() public {
    vm.expectRevert();
    dNft.addLiquidator(address(this));
    assertFalse(dNft.isLiquidator(address(this)));
  }

  // -------------------- grant --------------------
  function test_grant() public {
    uint id = dNft.mintNft{value: dNft.ETH_SACRIFICE()}(address(this));
    (bool hasPermission,) = dNft.id2permission(id, address(this));
    assertFalse(hasPermission);
    dNft.grant(id, address(this));
    (hasPermission,) = dNft.id2permission(id, address(this));
    assertTrue(hasPermission);

    vm.prank(address(1));
    vm.roll(block.number + 1);
    assertTrue(dNft.hasPermission(id, address(this)));
  }

  // -------------------- revoke --------------------
  function test_revoke() public {
    uint id = dNft.mintNft{value: dNft.ETH_SACRIFICE()}(address(this));
    dNft.grant(id, address(this));
    (bool hasPermission,) = dNft.id2permission(id, address(this));
    assertTrue(hasPermission);
    dNft.revoke(id, address(this));
    (hasPermission,) = dNft.id2permission(id, address(this));
    assertFalse(hasPermission);

    vm.roll(block.number + 1);
    hasPermission = dNft.hasPermission(id, address(1));
    assertFalse(hasPermission);
  }
}
