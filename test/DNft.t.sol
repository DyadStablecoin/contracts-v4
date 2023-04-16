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
    dNft.mintNft(0, address(this));
  }
  function testCannot_mintNft_sameTicket() public {
    dNft.mintNft(0, address(this));
    vm.expectRevert();
    dNft.mintNft(0, address(this));
  }
  function testCannot_mintNft_publicMintsExceeded() public {
    for(uint i = 0; i < dNft.PUBLIC_MINTS(); i++) {
      dNft.mintNft(i, address(this));
      zoraMock.safeMint(address(this), i+1);
    }
    uint id = dNft.PUBLIC_MINTS()+1;
    zoraMock.safeMint(address(this), id);
    vm.expectRevert();
    dNft.mintNft(id, address(this));
  }

  // // -------------------- mintInsiderNft --------------------
  // function test_mintInsiderNft() public {
  //   vm.prank(MAINNET_OWNER);
  //   dNft.mintNft(0, address(this));
  // }
  // function testCannot_mintInsiderNft_NotOwner() public {
  //   vm.expectRevert();
  //   dNft.mintInsiderNft(address(this));
  // }
  // function testCannot_mintInsiderNft_insiderMintsExceeded() public {
  //   for(uint i = 0; i < dNft.INSIDER_MINTS(); i++) {
  //     dNft.mintNft(0, address(this));
  //   }
  //   vm.expectRevert();
  //   dNft.mintInsiderNft(address(this));
  // }

  // -------------------- grant --------------------
  function test_grant() public {
    uint id = dNft.mintNft(0, address(this));
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
    uint id = dNft.mintNft(0, address(this));
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
