contract C {
    function f(uint x) public pure {
        uint a = 3;
        if (x > 10) {
            ++a;
        }
        assert(a == 3);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (127-141): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 11\na = 4\n\nTransaction trace:\nC.constructor()\nC.f(11)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
