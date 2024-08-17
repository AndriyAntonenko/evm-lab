// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Initializable } from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

import { CREATE3 } from "lib/solady/src/utils/CREATE3.sol";

contract UpgradableCreate3Factory is Initializable, UUPSUpgradeable, OwnableUpgradeable {
  constructor() {
    _disableInitializers();
  }

  function initialize(address admin) external initializer {
    __Ownable_init(admin);
  }

  function _authorizeUpgrade(address) internal override onlyOwner { }

  function predictAddress(bytes32 _salt) external view virtual returns (address) {
    return CREATE3.predictDeterministicAddress(_salt);
  }

  function createChild(address expectedAddress, bytes32 _salt) external virtual {
    address createdAddress = CREATE3.deployDeterministic(type(Child).creationCode, _salt);
    require(createdAddress == expectedAddress, "UpgradableCreate3Creator: INVALID_ADDRESS");
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
