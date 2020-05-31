// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import { RStoreLib } from "./RStoreLib.sol";
import { BitsLib } from "./BitsLib.sol";

library JumpdestScannerLib {
  using BitsLib for *;
  uint256 constant OP_JUMPDEST = 0x5b;
  uint256 constant OP_JUMP_START = 0x60;
  uint256 constant OP_JUMP_END = 0x60 + 0x20;
  function getFreePtr() internal pure returns (uint256 result) {
    assembly {
      result := mload(0x40)
    }
  }
  function toPtr(bytes memory buffer) internal pure returns (uint256 ptr) {
    assembly {
      ptr := add(buffer, 0x20)
    }
  }
  function loadByte(uint256 ptr, uint256 index) internal pure returns (uint256 result) {
    assembly {
      result := and(mload(add(sub(ptr, 0x1f), index)), 0xff)
    }
  }
  function generateJumpdestMap(bytes memory runtimeCode) internal pure returns (bytes memory) {
    bytes memory result = new bytes((runtimeCode.length + 8) / 8); // make sure freeptr gets fixed
    uint256 ptr = toPtr(result);
    uint256 codePtr = toPtr(runtimeCode);
    uint256 lastSeen = 0;
    for (uint256 i = 0; i < runtimeCode.length;) {
      uint256 op = loadByte(codePtr, i);
      if (op >= OP_JUMP_START && op < OP_JUMP_END) {
        i += op - OP_JUMP_START + 1; // constexpr, hopefully solc optimizes this
      } else if (op == OP_JUMPDEST) {
        ptr.setBit(i);
	lastSeen = i;
        i++;
      } else i++;
    } 
    uint256 length = (lastSeen + 8) / 8; // fit to the minimum amount ot bytes for the bitfield
    assembly {
      mstore(result, length)
    }
    return result;
  }
  function storeJumpdestMap(bytes memory runtimeCode, bytes32 salt) internal returns (address result) {
    result = RStoreLib.store(generateJumpdestMap(runtimeCode), salt);
  }
}
