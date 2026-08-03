contract C {
    function f(uint x, uint y) public pure {
        assembly {}
        assert(x < y);
    }

    function g(uint x, uint y) public pure {
        assembly {}
        assert(x < y);
    }
}
// ====
// SMTEngine: all
// SMTShowUnsupported: no
// ----
// Warning 5724: SMTChecker: 2 unsupported language feature(s). Enable the model checker option "show unsupported" to see all of them.
// Warning 6328: (86-99): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\ny = 0\n\nTransaction trace:\nC.constructor()\nC.f(0, 0)
// Warning 6328: (181-194): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\ny = 0\n\nTransaction trace:\nC.constructor()\nC.g(0, 0)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
