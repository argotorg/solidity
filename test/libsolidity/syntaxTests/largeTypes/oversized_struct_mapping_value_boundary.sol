// The storage size upper bound of S is 1 + 2**255 + (2**255 - 1) == 2**256.
struct S {
    uint[2**255] a;
    uint[2**255 - 1] b;
}
contract C {
    mapping(uint => S) m;
}
// ----
// TypeError 1534: (151-171): Type too large for storage.
