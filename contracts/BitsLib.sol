// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

library BitsLib {
  function setBit(uint256 ptrStart, uint256 bitPosition) internal pure {
    assembly {
      let bytePosition := div(bitPosition, 0x8)
      let ptr := add(ptrStart, bytePosition)
      mstore8(ptr, or(mload(sub(ptr, 0x1f)), shr(and(0x7, bitPosition), 0x80)))
    }
  }
}
