struct M {
    uint[2**27] a;
}
contract C {
    function f(bytes memory d) public pure {
        abi.decode(d, (M[]));
    }
}
// ----
// TypeError 6118: (113-116): Type too large for memory.
