contract C {
    // a and b share a slot: 2**64 - 1 slots.
    struct P {
        uint8 a;
        uint8 b;
        uint[2**64 - 2] c;
    }
    // a and c cannot share a slot: 2**64 slots.
    struct Q {
        uint8 a;
        uint[2**64 - 2] b;
        uint8 c;
    }
    P p;
    Q q;
}
// ----
// Warning 7325: (276-277): Type struct C.P covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 7325: (285-286): Type struct C.Q covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 2119: (285-286): Type struct C.Q spans 2**64 or more slots. Such oversized types are deprecated and will be disallowed in a future breaking release.
