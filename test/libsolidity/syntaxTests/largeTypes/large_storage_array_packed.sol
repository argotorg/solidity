contract C {
    // 2**59 slots, 32 items per slot.
    uint8[2**64] a;
    // 2**64 - 1 slots.
    uint8[2**69 - 32] b;
    // Exactly 2**64 slots.
    uint8[2**69] c;
}
// ----
// Warning 7325: (56-68): Type uint8[18446744073709551616] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 7325: (100-117): Type uint8[590295810358705651680] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 7325: (153-165): Type uint8[590295810358705651712] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 2119: (153-165): Type uint8[590295810358705651712] spans 2**64 or more slots. Such oversized types are deprecated and will be disallowed in a future breaking release.
