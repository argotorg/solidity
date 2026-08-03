contract C {
    function f(uint a) internal pure returns (uint b) {
        require(a < 1000);
        return a * a;
    }
    function g(uint a) internal pure returns (uint b) {
        require(a < 1000);
        return a + 100;
    }
    function h(uint a) public pure {
        uint c = a < 5 ? g(a) : f(a);
        assert(c >= 25);
        assert(c < 20); // should fail
    }
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (345-359): CHC: Assertion violation happens here.\nCounterexample:\n\na = 5\nc = 25\n\nTransaction trace:\nC.constructor()\nC.h(5)\n    C.g(5) -- internal call\n    C.f(5) -- internal call
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
