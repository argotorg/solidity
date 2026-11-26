struct S {
    uint[2**40] x;
    function() internal f;
}
struct P {
    S[] s;
}
contract C {
    function f(S calldata) internal {}
    function g(P calldata) internal {}
}
// ----
// TypeError 1534: (111-121): Type too large for calldata.
// TypeError 1534: (150-160): Type too large for calldata.
