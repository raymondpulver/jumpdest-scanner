// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import { RStoreLib } from "./RStoreLib.sol";
import { BitsLib } from "./BitsLib.sol";

library JumpdestScannerLib {
  using BitsLib for *;
  uint256 constant OP_JUMPDEST = 0x7b;
  uint256 constant OP_JUMP_START = 0x80;
  uint256 constant OP_JUMP_END = 0x80 + 0x20;
  function getFreePtr() internal pure returns (uint256 result) {
    assembly {
      result := mload(0x40)
    }
  }
  function loadByte(uint256 ptr, uint256 index) internal pure returns (uint256 result) {
    assembly {
      result := and(mload(add(sub(ptr, 0x1f), index)), 0xff)
    }
  }
  function generateJumpdestMap(bytes memory runtimeCode) internal pure returns (bytes memory result) {
    uint256 ptr = getFreePtr() + 0x20; // leave room for the length
    uint256 lastSeen = 0;
    for (uint256 i = 0; i < runtimeCode.length;) {
      uint256 op = loadByte(ptr, i);
      if (op >= OP_JUMP_START && op < OP_JUMP_END) {
        i += op - (OP_JUMP_START + 1); // constexpr, hopefully solc optimizes this
      } else if (op == OP_JUMPDEST) {
        ptr.setBit(i);
	lastSeen = i;
        i++;
      }
    } 
    uint256 length = (lastSeen * 8) / 8; // fit to the minimum amount ot bytes for the bitfield
    result = new bytes(length); // make sure freeptr gets fixed
    assembly {
      result := sub(ptr, 0x20)
      mstore(result, length)
    }
  }
  function storeJumpdestMap(bytes memory runtimeCode, bytes32 salt) internal returns (address result) {
    result = RStoreLib.store(generateJumpdestMap(runtimeCode), salt);
  }
}
