// The total size of P is 2**31 + 2**31 == 2**32.
struct P {
    uint[2**26] a;
    uint[2**26] b;
}
contract C {
    function f(P memory) public pure {}
}
// ----
// TypeError 1534: (129-137): Type too large for memory.
