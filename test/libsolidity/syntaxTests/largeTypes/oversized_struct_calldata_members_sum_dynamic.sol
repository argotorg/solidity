// The head size of P is 2**31 + 2**31 + 32 > 2**32.
struct P {
    uint[2**26] a;
    uint[2**26] b;
    uint[] c;
}
contract C {
    function f(P calldata) external pure {}
}
// ----
// TypeError 1534: (146-156): Type too large for calldata.
