// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";
import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";
import { LibClone } from "lib/solady/src/utils/LibClone.sol";

import {
  UpgradableCreate2Factory, Child
} from "../../../src/security/create2-factory-upgrade/UpgradableCreate2Factory.sol";

contract UpgradableCreate2FactoryTest is Test {
  address private immutable i_admin = makeAddr("admin");
  UpgradableCreate2Factory private factory;

  function setUp() public {
    UpgradableCreate2Factory impl = new UpgradableCreate2Factory();
    factory = UpgradableCreate2Factory(LibClone.deployERC1967(address(impl)));
    factory.initialize(i_admin);
  }

  /// @notice Here the issue scenario
  function test_upgradeAddressMismatchWithChildCodeChange() public {
    // step 1: predict the address of the child contract
    bytes32 salt = 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;
    address expectedAddress = factory.predictAddress(salt);

    // step 2: admin upgrades the factory to a new implementation with changed child code
    NewUpgradableCreate2Factory newImpl = new NewUpgradableCreate2Factory();
    vm.prank(i_admin);
    factory.upgradeToAndCall(address(newImpl), "");

    // step 3: create of the child with the expected address will revert, cause address mismatch
    vm.expectRevert();
    factory.createChild(expectedAddress, salt);
  }
}

/*//////////////////////////////////////////////////////////////
            UPGRADED FACTORY WITH CHANGED CHILD CODE
//////////////////////////////////////////////////////////////*/

contract NewUpgradableCreate2Factory is UpgradableCreate2Factory {
  constructor() { }

  function predictAddress(bytes32 _salt) external view override returns (address) {
    bytes32 bytecodeHash = keccak256(abi.encodePacked(type(NewChild).creationCode, address(this)));
    return Create2.computeAddress(_salt, bytecodeHash);
  }

  function createChild(address expectedAddress, bytes32 _salt) external override {
    address createdAddress = Create2.deploy(0, _salt, abi.encodePacked(type(NewChild).creationCode, address(this)));
    require(createdAddress == expectedAddress, "UpgradableCreate2Factory: INVALID_ADDRESS");
  }
}

contract NewChild is Child {
  function test() public pure returns (string memory) {
    return "NewChild";
  }
}
