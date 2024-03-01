// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract HorseStore {
  uint256 s_numberOfHorses;

  function updateHorseNumber(uint256 newNumberOfHorses) external {
    s_numberOfHorses = newNumberOfHorses;
  }

  function readNumberOfHorses() external view returns (uint256) {
    return s_numberOfHorses;
  }
}
