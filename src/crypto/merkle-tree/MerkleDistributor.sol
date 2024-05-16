// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MerkleDistributor {
  using SafeERC20 for IERC20;

  IERC20 private immutable i_token;
  bytes32 private immutable i_merkleRoot;

  mapping(address => bool) private claimed;

  event Claimed(address indexed account, uint256 amount, uint256 timestamp);

  error AlreadyClaimed(address account);
  error InvalidMerkleProof();

  constructor(address _token, bytes32 _merkleRoot) {
    i_token = IERC20(_token);
    i_merkleRoot = _merkleRoot;
  }

  function claim(address _account, uint256 _amount, bytes32[] calldata _merkleProof) external {
    if (claimed[_account]) revert AlreadyClaimed(_account);

    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));

    if (!MerkleProof.verifyCalldata(_merkleProof, i_merkleRoot, leaf)) {
      revert InvalidMerkleProof();
    }

    claimed[_account] = true;

    i_token.safeTransfer(_account, _amount);

    emit Claimed(_account, _amount, block.timestamp);
  }

  function isClaimed(address _account) external view returns (bool) {
    return claimed[_account];
  }
}
