// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import { ERC20Mock } from "../mocks/ERC20Mock.sol";
import { MerkleDistributor } from "../../src/crypto/merkle-tree/MerkleDistributor.sol";

contract MerkleTreeDistributorTest is Test {
  ERC20Mock private token;
  MerkleDistributor private distributor;

  // Check the data from the ./src/crypto/merkle-tree/merkle-tree.json and the script
  // ./src/crypto/merkle-tree/merkle-tree.js
  bytes32 private constant MERKLE_ROOT = 0x82755244fbe4b672fca8292e8a05435baa53138779d85270d9e1b6595699cb0d;

  address private constant RECEPIENT = 0x1111111111111111111111111111111111111111;
  uint256 private constant AMOUNT = 5_000_000_000_000_000_000;
  bytes32 private immutable MERKLE_NODE = keccak256(abi.encodePacked(RECEPIENT, AMOUNT));

  function setUp() public {
    token = new ERC20Mock("Test Token", "TTK");
    distributor = new MerkleDistributor(address(token), MERKLE_ROOT);
  }

  function testClaim() public {
    bytes32[] memory merkleProof = new bytes32[](3);
    merkleProof[0] = 0xf8330a2c877270873c192c2bc9468a45f87284fcf68ef5c8aeed39a26721e6eb;
    merkleProof[1] = 0x1425d0ec857f077c2075a061b77410a445d2cee2d9c05a8ee74b8f5d2e37f932;
    merkleProof[2] = 0x215021632d1e9ccddb6f5a712c104203bf6dfd6ba69f2a941ab96cc5eaf08561;

    deal(address(token), address(distributor), AMOUNT);
    distributor.claim(RECEPIENT, AMOUNT, merkleProof);

    console.log("receiver TTK balance", token.balanceOf(RECEPIENT));
    assert(token.balanceOf(RECEPIENT) == AMOUNT);
    assert(distributor.isClaimed(RECEPIENT) == true);
  }
}
