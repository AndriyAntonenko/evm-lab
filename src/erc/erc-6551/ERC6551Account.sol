// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC1271 } from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { IERC6551Account } from "./interfaces/IERC6551Account.sol";
import { IERC6551Executable } from "./interfaces/IERC6551Executable.sol";

contract ERC6551Account is IERC165, IERC1271, IERC6551Account, IERC6551Executable {
  uint256 public state;

  receive() external payable { }

  function execute(
    address to,
    uint256 value,
    bytes calldata data,
    uint8 operation
  )
    external
    payable
    virtual
    returns (bytes memory result)
  {
    require(_isValidSigner(msg.sender), "ERC6551Account: invalid signer");
    require(operation == 0, "ERC6551Account: only CALL operation supported");

    ++state;
    bool success;
    (success, result) = to.call{ value: value }(data);

    if (!success) {
      assembly {
        revert(add(result, 32), mload(result))
      }
    }
  }

  function token() public view virtual returns (uint256 chainId, address tokenContract, uint256 tokenId) {
    bytes memory footer = new bytes(0x60);

    assembly {
      extcodecopy(address(), add(footer, 0x20), 0x4d, 0x60)
    }

    (chainId, tokenContract, tokenId) = abi.decode(footer, (uint256, address, uint256));
  }

  function owner() public view virtual returns (address) {
    (uint256 chainId, address tokenContract, uint256 tokenId) = token();
    if (chainId != block.chainid) return address(0);

    return IERC721(tokenContract).ownerOf(tokenId);
  }

  function isValidSignature(bytes32 hash, bytes memory signature) external view virtual returns (bytes4 magicValue) {
    bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

    if (isValid) {
      return IERC1271.isValidSignature.selector;
    }

    return bytes4(0);
  }

  function isValidSigner(address signer, bytes calldata) external view virtual returns (bytes4) {
    if (_isValidSigner(signer)) {
      return IERC6551Account.isValidSigner.selector;
    }

    return bytes4(0);
  }

  function _isValidSigner(address signer) internal view virtual returns (bool) {
    return signer == owner();
  }

  function supportsInterface(bytes4 interfaceId) external pure virtual returns (bool) {
    return interfaceId == type(IERC165).interfaceId || interfaceId == type(IERC6551Account).interfaceId
      || interfaceId == type(IERC6551Executable).interfaceId;
  }
}
