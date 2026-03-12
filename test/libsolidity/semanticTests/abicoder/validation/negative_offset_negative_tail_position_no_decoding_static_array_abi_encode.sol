contract C {
    // Access at every nesting level must be validated against reading outside of the [0, calldatasize() - 1] range.
    // NOTE: Passing a calldata type into abi.encode() does not trigger decoding.
    // The encoded data is just copied. All validations expected during normal decoding must still run though.
    function accessTop(bytes[1][1][1] calldata a) external     returns (bytes memory) { return abi.encode(a); }
    function accessMiddle(bytes[1][1][1] calldata a) external  returns (bytes memory) { return abi.encode(a[0]); }
    function accessBottom(bytes[1][1][1] calldata a) external  returns (bytes memory) { return abi.encode(a[0][0]); }
    function accessContent(bytes[1][1][1] calldata a) external returns (bytes memory) { return abi.encode(a[0][0][0]); }
}
// Every case below which uses -999 as offset has tail at a negative position and should revert.
// ====
// revertStrings: debug
// ----
// accessTop(bytes[1][1][1]): 0x20, 0x20, 0x20, 0x20, 0  -> 0x20, 160, 0x20, 0x20, 0x20, 0x20, 0
// accessTop(bytes[1][1][1]): 0x20, 0x20, 0x20, -999 ->     0x20, 160, 0x20, 0x20, 0x20, 0x20, 0
// accessTop(bytes[1][1][1]): 0x20, 0x20, -999 ->           0x20, 160, 0x20, 0x20, 0x20, 0x20, 0
// accessTop(bytes[1][1][1]): 0x20, -999 ->                 0x20, 160, 0x20, 0x20, 0x20, 0x20, 0
// accessTop(bytes[1][1][1]): -999 ->                       FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"

// accessMiddle(bytes[1][1][1]): 0x20, 0x20, 0x20, 0x20, 0 -> 0x20, 128, 0x20, 0x20, 0x20, 0
// accessMiddle(bytes[1][1][1]): 0x20, 0x20, 0x20, -999 ->    0x20, 128, 0x20, 0x20, 0x20, 0
// accessMiddle(bytes[1][1][1]): 0x20, 0x20, -999 ->          0x20, 128, 0x20, 0x20, 0x20, 0
// accessMiddle(bytes[1][1][1]): 0x20, -999 ->                0x20, 128, 0x20, 0x20, 0x20, 0
// accessMiddle(bytes[1][1][1]): -999 ->                      FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"

// accessBottom(bytes[1][1][1]): 0x20, 0x20, 0x20, 0x20, 0 -> 0x20, 96, 0x20, 0x20, 0
// accessBottom(bytes[1][1][1]): 0x20, 0x20, 0x20, -999 ->    0x20, 96, 0x20, 0x20, 0
// accessBottom(bytes[1][1][1]): 0x20, 0x20, -999 ->          0x20, 96, 0x20, 0x20, 0
// accessBottom(bytes[1][1][1]): 0x20, -999 ->                0x20, 96, 0x20, 0x20, 0
// accessBottom(bytes[1][1][1]): -999 ->                      FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"

// accessContent(bytes[1][1][1]): 0x20, 0x20, 0x20, 0x20, 0 -> 0x20, 64, 0x20, 0
// accessContent(bytes[1][1][1]): 0x20, 0x20, 0x20, -999 ->    0x20, 64, 0x20, 0
// accessContent(bytes[1][1][1]): 0x20, 0x20, -999 ->          0x20, 64, 0x20, 0
// accessContent(bytes[1][1][1]): 0x20, -999 ->                0x20, 64, 0x20, 0
// accessContent(bytes[1][1][1]): -999 ->                      FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"
