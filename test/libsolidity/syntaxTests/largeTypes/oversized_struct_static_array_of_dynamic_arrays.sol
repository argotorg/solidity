struct S {
    uint[2**255] a;
    uint[2**255] b;
}
contract C {
    S[][2] d;
}
// ----
// TypeError 1534: (70-78): Type too large for storage.
