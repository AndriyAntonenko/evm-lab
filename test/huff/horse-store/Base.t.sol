// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IHorseStore } from "../../../src/huff/horse-store-erc721/IHorseStore.sol";
import { HorseStore } from "../../../src/huff/horse-store-erc721/HorseStore.sol";
import { Test, console2 } from "forge-std/Test.sol";

abstract contract BaseTest is Test {
  using console2 for *;

  HorseStore horseStore;
  address user = makeAddr("user");
  string public constant NFT_NAME = "HorseStore";
  string public constant NFT_SYMBOL = "HS";

  event Transfer(address indexed from, address indexed to, uint256 tokenId);

  function setUp() public virtual {
    horseStore = new HorseStore();
  }

  function testName() public {
    string memory name = horseStore.name();
    assertEq(name, NFT_NAME);
  }

  function testSymbol() public {
    string memory symbol = horseStore.symbol();
    assertEq(symbol, NFT_SYMBOL);
  }

  function testMintingHorseAssignsOwner(address randomOwner) public {
    vm.assume(randomOwner != address(0));
    vm.assume(!_isContract(randomOwner));

    uint256 horseId = horseStore.totalSupply();
    vm.prank(randomOwner);
    horseStore.mintHorse();
    assertEq(horseStore.ownerOf(horseId), randomOwner);
  }

  function testMintingHorseIncreasesBalance(address randomOwner) public {
    vm.assume(randomOwner != address(0));
    vm.assume(!_isContract(randomOwner));

    uint256 balanceBefore = horseStore.balanceOf(randomOwner);
    vm.prank(randomOwner);
    horseStore.mintHorse();
    uint256 balanceAfter = horseStore.balanceOf(randomOwner);
    assertEq(balanceAfter, balanceBefore + 1);
  }

  function testFeedingHorseOnlyOwnerCanFeed(address randomOwner, address anotherUser) public {
    vm.assume(randomOwner != address(0));
    vm.assume(!_isContract(randomOwner));

    uint256 horseId = horseStore.totalSupply();
    vm.prank(randomOwner);
    horseStore.mintHorse();
    vm.prank(anotherUser);
    vm.expectRevert(IHorseStore.ForbiddenError.selector);
    horseStore.feedHorse(horseId);
  }

  function testFeedingHorseUpdatesTimestamps(address randomOwner) public {
    vm.assume(randomOwner != address(0));
    vm.assume(!_isContract(randomOwner));

    uint256 horseId = horseStore.totalSupply();
    vm.warp(10);
    vm.roll(10);

    vm.startPrank(randomOwner);
    horseStore.mintHorse();
    uint256 lastFedTimeStamp = block.timestamp;
    horseStore.feedHorse(horseId);
    vm.stopPrank();
    assertEq(horseStore.horseIdToFedTimeStamp(horseId), lastFedTimeStamp);
  }

  function testFeedingMakesHappyHorse(address randomOwner) public {
    vm.assume(randomOwner != address(0));
    vm.assume(!_isContract(randomOwner));

    uint256 horseId = horseStore.totalSupply();
    vm.warp(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
    vm.roll(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
    vm.startPrank(randomOwner);
    horseStore.mintHorse();
    horseStore.feedHorse(horseId);
    vm.stopPrank();
    assertEq(horseStore.isHappyHorse(horseId), true);
  }

  function testNotFeedingMakesUnhappyHorse(address randomOwner) public {
    vm.assume(randomOwner != address(0));
    vm.assume(!_isContract(randomOwner));

    uint256 horseId = horseStore.totalSupply();
    vm.warp(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
    vm.roll(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
    vm.prank(randomOwner);
    horseStore.mintHorse();
    assertEq(horseStore.isHappyHorse(horseId), false);
  }

  function testHorseIsHappyIfFedWithinPast24Hours(uint256 checkAt, address randomOwner) public {
    vm.assume(randomOwner != address(0));
    vm.assume(!_isContract(randomOwner));

    uint256 fedAt = horseStore.HORSE_HAPPY_IF_FED_WITHIN();
    checkAt = bound(checkAt, fedAt + 1 seconds, fedAt + horseStore.HORSE_HAPPY_IF_FED_WITHIN() - 1 seconds);
    vm.warp(fedAt);
    vm.startPrank(randomOwner);
    uint256 horseId = horseStore.totalSupply();
    horseStore.mintHorse();
    horseStore.feedHorse(horseId);
    vm.stopPrank();

    vm.warp(checkAt);
    assertEq(horseStore.isHappyHorse(horseId), true);
  }

  function testErc721Approval(address randomOwner, address randomSpender) public {
    vm.assume(randomOwner != address(0));
    vm.assume(!_isContract(randomOwner));
    vm.assume(randomSpender != address(0));
    vm.assume(!_isContract(randomSpender));

    uint256 horseId = horseStore.totalSupply();
    vm.prank(randomOwner);
    horseStore.mintHorse();
    vm.prank(randomOwner);
    horseStore.approve(randomSpender, horseId);
    assertEq(horseStore.getApproved(horseId), randomSpender);
  }

  /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
  // Borrowed from an Old Openzeppelin codebase
  function _isContract(address account) internal view returns (bool) {
    // This method relies on extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.

    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }
}
