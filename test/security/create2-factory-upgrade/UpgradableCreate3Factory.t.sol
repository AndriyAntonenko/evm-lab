// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";
import { CREATE3 } from "lib/solady/src/utils/CREATE3.sol";
import { LibClone } from "lib/solady/src/utils/LibClone.sol";

import {
  UpgradableCreate3Factory, Child
} from "../../../src/security/create2-factory-upgrade/UpgradableCreate3Factory.sol";

contract UpgradableCreate3FactoryTest is Test {
  address private immutable i_admin = makeAddr("admin");
  UpgradableCreate3Factory private factory;

  function setUp() public {
    UpgradableCreate3Factory impl = new UpgradableCreate3Factory();
    factory = UpgradableCreate3Factory(LibClone.deployERC1967(address(impl)));
    factory.initialize(i_admin);
  }

  function test_UpgradeAddressNotMismatchForCREATE3() public {
    bytes32 salt = 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;
    address expectedAddress = factory.predictAddress(salt);

    NewUpgradableCreate3Factory newImpl = new NewUpgradableCreate3Factory();
    vm.prank(i_admin);
    factory.upgradeToAndCall(address(newImpl), "");

    factory.createChild(expectedAddress, salt);
  }
}

contract NewUpgradableCreate3Factory is UpgradableCreate3Factory {
  constructor() { }

  function predictAddress(bytes32 _salt) external view override returns (address) {
    return CREATE3.predictDeterministicAddress(_salt);
  }

  function createChild(address expectedAddress, bytes32 _salt) external override {
    address createdAddress =
      CREATE3.deployDeterministic(abi.encodePacked(type(NewChild).creationCode, address(this)), _salt);
    require(createdAddress == expectedAddress, "UpgradableCreate3Factory: INVALID_ADDRESS");
  }
}

contract NewChild is Child {
  function test() public pure returns (string memory) {
    return "NewChild";
  }
}
