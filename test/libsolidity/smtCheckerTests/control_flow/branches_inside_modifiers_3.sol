contract C {
    uint x;
    modifier m(uint z) {
		uint y = 3;
        if (z == 10)
            x = 2 + y;
        _;
        if (z == 10)
            x = 4 + y;
    }
    function f() m(8) internal {
        x = 3;
    }
    function g() public {
        x = 0;
        f();
        assert(x == 3);
        // Fails
        assert(x == 6);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (326-340): CHC: Assertion violation happens here.\nCounterexample:\nx = 3\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.g()\n    C.f() -- internal call
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
