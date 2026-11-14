contract C {
    struct S { uint[2**30] x; uint[2**50] y; }
    S[2**20] x;
}
// ----
// Warning 7325: (64-72): Type struct C.S[1048576] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 2119: (64-72): Type struct C.S[1048576] spans 2**64 or more slots. Such oversized types are deprecated and will be disallowed in the next breaking release.
