struct S {
    uint[2**255] a;
    uint[2**255] b;
}
contract C {
    mapping(uint => mapping(uint => S)) m;
}
// ----
// TypeError 1534: (70-107): Type too large for storage.
