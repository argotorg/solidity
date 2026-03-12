contract C {
    // `content` is dynamic so all the structs here are as well. Each one has a head and a tail when ABI-encoded.
    // Encoded `Top` looks like this: [t offset][m offset][b offset][content offset][content size][content data].
    // This lets us play with offsets at different nesting levels.
    struct Bottom { bytes content; }
    struct Middle { Bottom b; }
    struct Top    { Middle m; }

    // Access at every nesting level must be validated against reading outside of the [0, calldatasize() - 1] range.
    // NOTE: Passing a calldata type into abi.encode() does not trigger decoding.
    // The encoded data is just copied. All validations expected during normal decoding must still run though.
    function accessTop(Top calldata t) external     returns (bytes memory) { return abi.encode(t); }
    function accessMiddle(Top calldata t) external  returns (bytes memory) { return abi.encode(t.m); }
    function accessBottom(Top calldata t) external  returns (bytes memory) { return abi.encode(t.m.b); }
    function accessContent(Top calldata t) external returns (bytes memory) { return abi.encode(t.m.b.content); }
}
// Every case below which uses -999 as offset has tail at a negative position and should revert.
// ====
// revertStrings: debug
// ----
// accessTop((((bytes)))): 0x20, 0x20, 0x20, 0x20, 0  -> 0x20, 160, 0x20, 0x20, 0x20, 0x20, 0
// accessTop((((bytes)))): 0x20, 0x20, 0x20, -999 ->     0x20, 160, 0x20, 0x20, 0x20, 0x20, 0
// accessTop((((bytes)))): 0x20, 0x20, -999 ->           0x20, 160, 0x20, 0x20, 0x20, 0x20, 0
// accessTop((((bytes)))): 0x20, -999 ->                 0x20, 160, 0x20, 0x20, 0x20, 0x20, 0
// accessTop((((bytes)))): -999 ->                       FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"

// accessMiddle((((bytes)))): 0x20, 0x20, 0x20, 0x20, 0 -> 0x20, 128, 0x20, 0x20, 0x20, 0
// accessMiddle((((bytes)))): 0x20, 0x20, 0x20, -999 ->    0x20, 128, 0x20, 0x20, 0x20, 0
// accessMiddle((((bytes)))): 0x20, 0x20, -999 ->          0x20, 128, 0x20, 0x20, 0x20, 0
// accessMiddle((((bytes)))): 0x20, -999 ->                0x20, 128, 0x20, 0x20, 0x20, 0
// accessMiddle((((bytes)))): -999 ->                      FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"

// accessBottom((((bytes)))): 0x20, 0x20, 0x20, 0x20, 0 -> 0x20, 96, 0x20, 0x20, 0
// accessBottom((((bytes)))): 0x20, 0x20, 0x20, -999 ->    0x20, 96, 0x20, 0x20, 0
// accessBottom((((bytes)))): 0x20, 0x20, -999 ->          0x20, 96, 0x20, 0x20, 0
// accessBottom((((bytes)))): 0x20, -999 ->                0x20, 96, 0x20, 0x20, 0
// accessBottom((((bytes)))): -999 ->                      FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"

// accessContent((((bytes)))): 0x20, 0x20, 0x20, 0x20, 0 -> 0x20, 64, 0x20, 0
// accessContent((((bytes)))): 0x20, 0x20, 0x20, -999 ->    0x20, 64, 0x20, 0
// accessContent((((bytes)))): 0x20, 0x20, -999 ->          0x20, 64, 0x20, 0
// accessContent((((bytes)))): 0x20, -999 ->                0x20, 64, 0x20, 0
// accessContent((((bytes)))): -999 ->                      FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"
