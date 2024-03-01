// SPDX-Licesne-Identifier: MIT
pragma solidity 0.8.20;

import { V1BaseTest } from "./V1Base.t.sol";
import { HuffDeployer } from "foundry-huff/HuffDeployer.sol";
import { HorseStore } from "../../../src/huff/horse-store/HorseStore.sol";

contract V1HorseStoreHuffTest is V1BaseTest {
  string public constant HORSE_STORE_HUFF_LOCATION = "huff/horse-store/HorseStore";

  function setUp() public override {
    s_horseStore = HorseStore(HuffDeployer.config().deploy(HORSE_STORE_HUFF_LOCATION));
  }
}
