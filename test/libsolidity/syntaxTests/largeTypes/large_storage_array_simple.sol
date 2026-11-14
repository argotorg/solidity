contract C {
    uint[2**64] x;
}
// ----
// Warning 7325: (17-28): Type uint256[18446744073709551616] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 2119: (17-28): Type uint256[18446744073709551616] spans 2**64 or more slots. Such oversized types are deprecated and will be disallowed in the next breaking release.
