contract C {
    // `content` is dynamic so all the structs here are as well. Each one has a head and a tail when ABI-encoded.
    // Encoded `Top` looks like this: [t offset][m offset][b offset][content offset][content size][content data].
    // This lets us play with offsets at different nesting levels.
    struct Bottom { bytes content; }
    struct Middle { Bottom b; }
    struct Top    { Middle m; }

    // Access at every nesting level must be validated against reading outside of the [0, calldatasize() - 1] range.
    // NOTE: Returning a calldata type as memory always results in the data being decoded.
    function accessTop(Top calldata t) external     returns (Top memory)    { return t; }
    function accessMiddle(Top calldata t) external  returns (Middle memory) { return t.m; }
    function accessBottom(Top calldata t) external  returns (Bottom memory) { return t.m.b; }
    function accessContent(Top calldata t) external returns (bytes memory)  { return t.m.b.content; }
}
// Every case below which uses -999 as offset has tail at a negative position and should revert.
// ====
// revertStrings: debug
// ----
// accessTop((((bytes)))): 0x20, 0x20, 0x20, 0x20, 0 -> 0x20, 0x20, 0x20, 0x20, 0
// accessTop((((bytes)))): 0x20, 0x20, 0x20, -999 -> FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"
// accessTop((((bytes)))): 0x20, 0x20, -999 ->       FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"
// accessTop((((bytes)))): 0x20, -999 ->             FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"
// accessTop((((bytes)))): -999 ->                   FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"

// accessMiddle((((bytes)))): 0x20, 0x20, 0x20, 0x20, 0 -> 0x20, 0x20, 0x20, 0
// accessMiddle((((bytes)))): 0x20, 0x20, 0x20, -999 -> FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"
// accessMiddle((((bytes)))): 0x20, 0x20, -999 ->       FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"
// accessMiddle((((bytes)))): 0x20, -999 ->             FAILURE, hex"08c379a0", 0x20, 39, "ABI decoding: invalid byte array", " length"
// accessMiddle((((bytes)))): -999 ->                   FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"

// accessBottom((((bytes)))): 0x20, 0x20, 0x20, 0x20, 0 -> 0x20, 0x20, 0
// accessBottom((((bytes)))): 0x20, 0x20, 0x20, -999 -> FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"
// accessBottom((((bytes)))): 0x20, 0x20, -999 ->       FAILURE, hex"08c379a0", 0x20, 39, "ABI decoding: invalid byte array", " length"
// accessBottom((((bytes)))): 0x20, -999 ->             FAILURE, hex"08c379a0", 0x20, 39, "ABI decoding: invalid byte array", " length"
// accessBottom((((bytes)))): -999 ->                   FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"

// accessContent((((bytes)))): 0x20, 0x20, 0x20, 0x20, 0 -> 0x20, 0
// accessContent((((bytes)))): 0x20, 0x20, 0x20, -999 -> FAILURE, hex"08c379a0", 0x20, 39, "ABI decoding: invalid byte array", " length"
// accessContent((((bytes)))): 0x20, 0x20, -999 ->       FAILURE, hex"08c379a0", 0x20, 39, "ABI decoding: invalid byte array", " length"
// accessContent((((bytes)))): 0x20, -999 ->             FAILURE, hex"08c379a0", 0x20, 39, "ABI decoding: invalid byte array", " length"
// accessContent((((bytes)))): -999 ->                   FAILURE, hex"08c379a0", 0x20, 34, "ABI decoding: invalid tuple offs", "et"
