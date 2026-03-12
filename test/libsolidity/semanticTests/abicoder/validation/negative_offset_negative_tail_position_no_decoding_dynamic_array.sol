contract C {
    // Access at every nesting level must be validated against reading outside of the [0, calldatasize() - 1] range.
    // NOTE: Returning the input as calldata does not trigger decoding.
    // The encoded data is just copied. All validations expected during normal decoding must still run though.
    function accessTop(bytes[][][] calldata a) external     returns (bytes[][][] calldata) { return a; }
    function accessMiddle(bytes[][][] calldata a) external  returns (bytes[][] calldata)   { return a[0]; }
    function accessBottom(bytes[][][] calldata a) external  returns (bytes[] calldata)     { return a[0][0]; }
    function accessContent(bytes[][][] calldata a) external returns (bytes calldata)       { return a[0][0][0]; }
}
// Every case below which uses -999 as offset has tail at a negative position and should revert.
// ====
// revertStrings: debug
// ----
// accessTop(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, 0x20, 0  -> 0x20, 1, 0x20, 1, 0x20, 1, 0x20, 0
// accessTop(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, -999 ->     0x20, 1, 0x20, 1, 0x20, 1, 0x20, 0
// accessTop(bytes[][][]): 0x20, 1, 0x20, 1, -999 ->              0x20, 1, 0x20, 1, 0x20, 0
// accessTop(bytes[][][]): 0x20, 1, -999 ->                       0x20, 1, 0x20, 0
// accessTop(bytes[][][]): -999 ->                                FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"

// accessMiddle(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, 0x20, 0 -> 0x20, 1, 0x20, 1, 0x20, 0
// accessMiddle(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, -999 ->    0x20, 1, 0x20, 1, 0x20, 0
// accessMiddle(bytes[][][]): 0x20, 1, 0x20, 1, -999 ->             0x20, 1, 0x20, 0
// accessMiddle(bytes[][][]): 0x20, 1, -999 ->                      0x20, 0
// accessMiddle(bytes[][][]): -999 ->                               FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"

// accessBottom(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, 0x20, 0 -> 0x20, 1, 0x20, 0
// accessBottom(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, -999 ->    0x20, 1, 0x20, 0
// accessBottom(bytes[][][]): 0x20, 1, 0x20, 1, -999 ->             0x20, 0
// accessBottom(bytes[][][]): 0x20, 1, -999 ->                      FAILURE, hex"4e487b71", 0x32
// accessBottom(bytes[][][]): -999 ->                               FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"

// accessContent(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, 0x20, 0 -> 0x20, 0
// accessContent(bytes[][][]): 0x20, 1, 0x20, 1, 0x20, 1, -999 ->    0x20, 0
// accessContent(bytes[][][]): 0x20, 1, 0x20, 1, -999 ->             FAILURE, hex"4e487b71", 0x32
// accessContent(bytes[][][]): 0x20, 1, -999 ->                      FAILURE, hex"4e487b71", 0x32
// accessContent(bytes[][][]): -999 ->                               FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"
