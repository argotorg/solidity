contract C {
    uint constant x = erc7201("A");
    uint[x] array;
}
// ----
// Warning 7325: (53-60): Type uint256[36579005187129934694193755934841191771209741707776365283473783080460440925696] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
