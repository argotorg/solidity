struct S {
    uint[2**255] a;
    uint[2**255] b;
}
struct T {
    mapping(uint => S) m;
}
contract C {
    T t;
}
// ----
// TypeError 1534: (109-112): Type too large for storage.
