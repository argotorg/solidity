contract C {
    function f() public pure returns (bytes1) {
        bytes1 a = 0xff;
        bytes1 b = 0xf0;
        b |= a;
        assert(a == b);

        a |= ~b;
        assert(a == 0); // fails
    }
}
// ====
// SMTEngine: all
// ----
// Warning 6321: (51-57): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
// Warning 6328: (177-191): CHC: Assertion violation happens here.\nCounterexample:\n\n = 0x0\na = 0xff\nb = 0xff\n\nTransaction trace:\nC.constructor()\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
