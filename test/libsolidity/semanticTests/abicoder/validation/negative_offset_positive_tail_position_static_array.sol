contract C {
    // Access at every nesting level must be validated against reading outside of the [0, calldatasize() - 1] range.
    // NOTE: Returning a calldata type as memory always results in the data being decoded.
    function accessTop(bytes[1][1][1] calldata a) external     returns (bytes[1][1][1] memory) { return a; }
    function accessMiddle(bytes[1][1][1] calldata a) external  returns (bytes[1][1] memory)    { return a[0]; }
    function accessBottom(bytes[1][1][1] calldata a) external  returns (bytes[1] memory)       { return a[0][0]; }
    function accessContent(bytes[1][1][1] calldata a) external returns (bytes memory)          { return a[0][0][0]; }
}
// Every case below has a structure that can technically be decoded without stepping outside of the
// [0, calldatasize() - 1] range if the overlap and negative offsets are handled correctly.
// Tail positions (absolute) are never negative even though the offsets (relative) are.
// ====
// revertStrings: debug
// ----
// accessTop(bytes[1][1][1]): 0x20, 0x20, 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0" -> 0x20, 0x20, 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0"
// accessTop(bytes[1][1][1]): 0x20, 0x20, 0x20, -32 ->                                                                                                                                          FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"
// accessTop(bytes[1][1][1]): 0x20, 0x20, -64 ->                                                                                                                                                FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"
// accessTop(bytes[1][1][1]): 0x20, -32 ->                                                                                                                                                      FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"

// accessMiddle(bytes[1][1][1]): 0x20, 0x20, 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0" -> 0x20, 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0"
// accessMiddle(bytes[1][1][1]): 0x20, 0x20, 0x20, -32 ->                                                                                                                                          FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"
// accessMiddle(bytes[1][1][1]): 0x20, 0x20, -64 ->                                                                                                                                                FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"
// accessMiddle(bytes[1][1][1]): 0x20, -32 ->                                                                                                                                                      FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"

// accessBottom(bytes[1][1][1]): 0x20, 0x20, 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0" -> 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0"
// accessBottom(bytes[1][1][1]): 0x20, 0x20, 0x20, -32 ->                                                                                                                                          FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"
// accessBottom(bytes[1][1][1]): 0x20, 0x20, -64 ->                                                                                                                                                0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xc0"
// accessBottom(bytes[1][1][1]): 0x20, -32 ->                                                                                                                                                      FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"

// accessContent(bytes[1][1][1]): 0x20, 0x20, 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0" -> 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0"
// accessContent(bytes[1][1][1]): 0x20, 0x20, 0x20, -32 ->                                                                                                                                          0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0"
// accessContent(bytes[1][1][1]): 0x20, 0x20, -64 ->                                                                                                                                                0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xc0"
// accessContent(bytes[1][1][1]): 0x20, -32 ->                                                                                                                                                      0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0"
