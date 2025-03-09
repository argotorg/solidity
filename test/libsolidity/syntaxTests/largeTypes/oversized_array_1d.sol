contract C {
    uint[2**256] x;
}
// ----
// TypeError 1847: (22-28): Array length too large, maximum is 2**256 - 1.
