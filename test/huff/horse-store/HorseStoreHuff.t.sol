// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { BaseTest, HorseStore } from "./Base.t.sol";
import { HuffDeployer } from "foundry-huff/HuffDeployer.sol";

contract HorseStoreHuff is BaseTest {
  string public constant horseStoreLocation = "huff/horse-store-erc721/HorseStore";

  function setUp() public override {
    horseStore = HorseStore(
      HuffDeployer.config().with_args(bytes.concat(abi.encode(NFT_NAME), abi.encode(NFT_SYMBOL))).deploy(
        horseStoreLocation
      )
    );
  }
}
