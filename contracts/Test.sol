// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

import { JumpdestScannerLib } from "./JumpdestScannerLib.sol";

contract Test {
  constructor(bytes memory runtimeCode) public {
    bytes memory map = JumpdestScannerLib.generateJumpdestMap(runtimeCode);
    assembly {
      return(add(0x20, map), mload(map))
    }
  }
}

