contract C {
    // The value type requires 2**256 slots, which is not rejected for mapping values.
    mapping(uint => uint[2**255][2]) a;
    // The value type requires 2**59 slots, while its upper bound is 2**64.
    mapping(uint => uint8[2**64]) b;
}
// ----
// Warning 7325: (104-136): Type uint256[57896044618658097711785492504343953926634992332820282019728792003956564819968][2] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 2119: (104-136): Type uint256[57896044618658097711785492504343953926634992332820282019728792003956564819968][2] spans 2**64 or more slots. Such oversized types are deprecated and will be disallowed in a future breaking release.
// Warning 7325: (104-136): Type uint256[57896044618658097711785492504343953926634992332820282019728792003956564819968] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 2119: (104-136): Type uint256[57896044618658097711785492504343953926634992332820282019728792003956564819968] spans 2**64 or more slots. Such oversized types are deprecated and will be disallowed in a future breaking release.
// Warning 7325: (220-249): Type uint8[18446744073709551616] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
