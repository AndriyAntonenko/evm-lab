// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Initializable } from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";

contract UpgradableCreate2Factory is Initializable, UUPSUpgradeable, OwnableUpgradeable {
  constructor() {
    _disableInitializers();
  }

  function initialize(address admin) external initializer {
    __Ownable_init(admin);
  }

  function _authorizeUpgrade(address) internal override onlyOwner { }

  function predictAddress(bytes32 _salt) external view virtual returns (address) {
    bytes32 bytecodeHash = keccak256(type(Child).creationCode);
    return Create2.computeAddress(_salt, bytecodeHash);
  }

  function createChild(address expectedAddress, bytes32 _salt) external virtual {
    address createdAddress = Create2.deploy(0, _salt, type(Child).creationCode);
    require(createdAddress == expectedAddress, "UpgradableCreate2Creator: INVALID_ADDRESS");
  }
}

contract Child {
  address public immutable i_owner;

  constructor() {
    i_owner = msg.sender;
  }

  function owner() external view returns (address) {
    return i_owner;
  }
}
