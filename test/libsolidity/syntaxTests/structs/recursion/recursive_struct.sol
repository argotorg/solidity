struct R {
    R[] a;
    mapping(uint => R) m;
    uint x;
}
contract C {
    R r;
    R[] d;
    mapping(uint => R) m;
}
// ----
