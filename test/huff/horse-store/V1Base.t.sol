// SPDX-Licesne-Identifier: MIT
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";
import { HorseStore } from "../../../src/huff/horse-store/HorseStore.sol";

abstract contract V1BaseTest is Test {
  HorseStore public s_horseStore;

  function setUp() public virtual {
    s_horseStore = new HorseStore();
  }

  function test_readHorseNumber() public {
    uint256 value = s_horseStore.readNumberOfHorses();
    assertEq(value, 0);
  }

  function test_updateHorseNumber(uint256 numberOfHorses) public {
    s_horseStore.updateHorseNumber(numberOfHorses);
    uint256 value = s_horseStore.readNumberOfHorses();
    assertEq(value, numberOfHorses);
  }
}
