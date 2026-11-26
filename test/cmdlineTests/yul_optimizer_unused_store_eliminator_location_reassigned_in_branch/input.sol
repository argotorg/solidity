// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

/// v3(1, val) must store val in slot 0.
contract V3 {
    function v3(uint256, uint256) external {
        assembly {
            let flag := calldataload(4)
            let val := calldataload(0x24)
            let ptr := mload(0x40)
            if flag { ptr := add(ptr, 0x20) }
            let readAt := add(ptr, 0x20)
            if flag { ptr := add(ptr, 0x20) }
            mstore(ptr, val)
            sstore(0, mload(readAt))
            stop()
        }
    }
}
