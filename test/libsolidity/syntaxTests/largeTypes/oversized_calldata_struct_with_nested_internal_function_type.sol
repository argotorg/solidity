struct S {
    function() internal f;
}
struct P {
    S s;
    uint[2**40] x;
}
contract C {
    function f(P calldata) internal {}
    function g(P[2] calldata) internal {}
}
// ----
// TypeError 1534: (109-119): Type too large for calldata.
// TypeError 1534: (148-161): Type too large for calldata.
