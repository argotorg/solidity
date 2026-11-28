struct S {
    uint[2**255] a;
    uint[2**255] b;
}
contract C {
    mapping(uint => S[]) m;
}
// ----
// TypeError 1534: (70-92): Type too large for storage.
