// The storage size upper bound of S is 1 + 2**255 + (2**255 - 2) == 2**256 - 1
// That is exactly the storage limit we impose
struct S {
    uint[2**255] a;
    uint[2**255 - 2] b;
}
contract C {
    mapping(uint => S) m;
    S[] d;
}
// ----
// Warning 7325: (201-219): Type struct S covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 7325: (201-219): Type uint256[57896044618658097711785492504343953926634992332820282019728792003956564819968] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 7325: (201-219): Type uint256[57896044618658097711785492504343953926634992332820282019728792003956564819966] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 7325: (227-230): Type struct S covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 7325: (227-230): Type uint256[57896044618658097711785492504343953926634992332820282019728792003956564819968] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
// Warning 7325: (227-230): Type uint256[57896044618658097711785492504343953926634992332820282019728792003956564819966] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
