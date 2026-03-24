contract C {
    uint[erc7201("length")] array;
}
// ----
// Warning 7325: (17-40): Type uint256[91485909057496517105622548919236807895873764128784270125752891283919605191424] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
