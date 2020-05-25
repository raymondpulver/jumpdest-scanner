pragma solidity ^0.6.0;

import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";
import { MemcpyLib } from "./MemcpyLib.sol";

library RStoreLib {
  function wrapWithCreationCode(bytes memory data) internal pure returns (bytes memory creationCode) {
    creationCode = hex"7f000000000000000000000000000000000000000000000000000000000000000080602a6000396000f3";
    uint256 length = data.length;
    bytes32 dest;
    bytes32 src;
    assembly {
      mstore(add(creationCode, 0x21), length)
      mstore(creationCode, add(0x2a, length))
      dest := add(creationCode, 0x4a)
      src := add(data, 0x20)
    }
    MemcpyLib.memcpy(dest, src, length);

  }
  function store(bytes memory segment, bytes32 salt) internal returns (address) {
    return Create2.deploy(0, salt, wrapWithCreationCode(segment));
  }
}
