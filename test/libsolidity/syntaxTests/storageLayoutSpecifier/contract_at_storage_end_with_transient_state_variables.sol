contract C layout at 2**256 - 1 {
    uint transient x;
    uint transient y;
    uint transient z;
}
// ====
// EVMVersion: >=cancun
// ----
// Warning 3495: (11-31): This contract is very close to the end of storage. This limits its future upgradability.
