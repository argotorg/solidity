// The head size of P is 2**31 + (2**31 - 64) + 32 == 2**32 - 32 bytes in calldata.
struct P {
    uint[2**26] a;
    uint[2**26 - 2] b;
    uint[] c;
}
contract C {
    function f(P calldata) external pure {}
}
