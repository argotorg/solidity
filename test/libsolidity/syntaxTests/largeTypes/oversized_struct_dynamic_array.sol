struct S {
    uint[2**255] a;
    uint[2**255] b;
}
contract C {
    S[] d;
}
// ----
// TypeError 1534: (70-75): Type too large for storage.
