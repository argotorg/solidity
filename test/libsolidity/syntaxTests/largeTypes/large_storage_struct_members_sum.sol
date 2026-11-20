contract C {
    // Members sum up to exactly 2**64 slots.
    struct S {
        uint[2**63] a;
        uint[2**63] b;
    }
    // Members sum up to 2**64 - 1 slots. The upper bound adds one slot for the struct.
    struct T {
        uint[2**63 - 1] a;
        uint[2**63] b;
    }
    S s;
    T t;
}
// ----
// Warning 7325: (289-290): Type struct C.S covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 2119: (289-290): Type struct C.S spans 2**64 or more slots. Such oversized types are deprecated and will be disallowed in a future breaking release.
// Warning 7325: (298-299): Type struct C.T covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
