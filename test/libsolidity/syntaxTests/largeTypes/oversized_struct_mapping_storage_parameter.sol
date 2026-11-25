struct S {
    uint[2**255] a;
    uint[2**255] b;
}
library L {
    function f(mapping(uint => S) storage) internal {}
}
// ----
// TypeError 1534: (80-106): Type too large for storage.
