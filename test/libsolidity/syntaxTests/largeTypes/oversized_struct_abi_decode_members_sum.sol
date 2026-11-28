// The total size of P is 2**31 + 2**31 == 2**32.
struct P {
    uint[2**26] a;
    uint[2**26] b;
}
contract C {
    function f(bytes memory d) public pure {
        abi.decode(d, (P));
    }
}
// ----
// TypeError 6118: (182-183): Type too large for memory.
