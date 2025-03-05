contract C {
    uint[2**256 - 1] x;
    uint transient y;
}
// ====
// EVMVersion: >=cancun
// ----
// Warning 7325: (17-33): Type uint256[115792089237316195423570985008687907853269984665640564039457584007913129639935] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
