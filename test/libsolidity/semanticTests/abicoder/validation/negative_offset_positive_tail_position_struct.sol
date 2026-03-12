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
// Every case below has a structure that can technically be decoded without stepping outside of the
// [0, calldatasize() - 1] range if the overlap and negative offsets are handled correctly.
// Tail positions (absolute) are never negative even though the offsets (relative) are.
// ====
// revertStrings: debug
// ----
// accessTop((((bytes)))): 0x20, 0x20, 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0" -> 0x20, 0x20, 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0"
// accessTop((((bytes)))): 0x20, 0x20, 0x20, -32 ->                                                                                                                                          FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"
// accessTop((((bytes)))): 0x20, 0x20, -64 ->                                                                                                                                                FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"
// accessTop((((bytes)))): 0x20, -32 ->                                                                                                                                                      FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"

// accessMiddle((((bytes)))): 0x20, 0x20, 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0" -> 0x20, 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0"
// accessMiddle((((bytes)))): 0x20, 0x20, 0x20, -32 ->                                                                                                                                          FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"
// accessMiddle((((bytes)))): 0x20, 0x20, -64 ->                                                                                                                                                FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"
// accessMiddle((((bytes)))): 0x20, -32 ->                                                                                                                                                      FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"

// accessBottom((((bytes)))): 0x20, 0x20, 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0" -> 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0"
// accessBottom((((bytes)))): 0x20, 0x20, 0x20, -32 ->                                                                                                                                          FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"
// accessBottom((((bytes)))): 0x20, 0x20, -64 ->                                                                                                                                                0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xc0"
// accessBottom((((bytes)))): 0x20, -32 ->                                                                                                                                                      FAILURE, hex"08c379a0", 0x20, 35, "ABI decoding: invalid struct off", "set"

// accessContent((((bytes)))): 0x20, 0x20, 0x20, 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0" -> 0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0"
// accessContent((((bytes)))): 0x20, 0x20, 0x20, -32 ->                                                                                                                                          0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0"
// accessContent((((bytes)))): 0x20, 0x20, -64 ->                                                                                                                                                0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xc0"
// accessContent((((bytes)))): 0x20, -32 ->                                                                                                                                                      0x20, 32, "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xe0"
