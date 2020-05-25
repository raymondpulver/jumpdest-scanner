// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

library BitsLib {
  function setBit(uint256 ptrStart, uint256 bitPosition) internal pure {
    assembly {
      mstore8(add(ptrStart, div(bitPosition, 0x8)), shr(and(0x7, bitPosition), 0x100))
    }
  }
}
