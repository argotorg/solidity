contract C {
    // Access at every nesting level must be validated against reading outside of the [0, calldatasize() - 1] range.
    // NOTE: Returning a calldata type as memory always results in the data being decoded.
    function accessTop(bytes[][][] calldata a) external     returns (bytes[][][] memory) { return a; }
    function accessMiddle(bytes[][][] calldata a) external  returns (bytes[][] memory)   { return a[0]; }
    function accessBottom(bytes[][][] calldata a) external  returns (bytes[] memory)     { return a[0][0]; }
    function accessContent(bytes[][][] calldata a) external returns (bytes memory)       { return a[0][0][0]; }
}
// Every case below has a structure that can technically be decoded without stepping outside of the
// [0, calldatasize() - 1] range if the overlap and negative offsets are handled correctly.
// Tail positions (absolute) are never negative even though the offsets (relative) are.
// ====
// revertStrings: debug
// ----
// accessTop(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, 0x20, 1, "\xff" -> 0x20, 1, 0x20, 1, 0x20, 1, 0x20, 1, "\xff"
// accessTop(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, -32 ->             FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"
// accessTop(bytes[][][]): 0x20, 1, 0x20, 1, -32 ->                      FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"
// accessTop(bytes[][][]): 0x20, 1, -32 ->                               FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"

// accessMiddle(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, 0x20, 1, "\xff" -> 0x20, 1, 0x20, 1, 0x20, 1, "\xff"
// accessMiddle(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, -32 ->             FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"
// accessMiddle(bytes[][][]): 0x20, 1, 0x20, 1, -32 ->                      FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"
// accessMiddle(bytes[][][]): 0x20, 1, -32 ->                               FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"

// accessBottom(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, 0x20, 1, "\xff" -> 0x20, 1, 0x20, 1, "\xff"
// accessBottom(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, -32 ->             FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"
// accessBottom(bytes[][][]): 0x20, 1, 0x20, 1, -32 ->                      FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"
// accessBottom(bytes[][][]): 0x20, 1, -32 ->                               FAILURE, hex"08c379a0", 0x20, 43, "ABI decoding: invalid calldata a", "rray offset"

// accessContent(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, 0x20, 1, "\xff" -> 0x20, 1, "\xff"
// accessContent(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, -32 ->             0x20, 1, "\xff"
// accessContent(bytes[][][]): 0x20, 1, 0x20, 1, -32 ->                      0x20, 1, "\xff"
// accessContent(bytes[][][]): 0x20, 1, -32 ->                               0x20, 1, "\xff"
