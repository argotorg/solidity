contract C {
    function f() public pure {
        bytes memory x = hex"00112233";
        assert(x[0] == 0x00);
        assert(x[1] == 0x11);
        assert(x.length == 3);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (152-173): CHC: Assertion violation happens here.\nCounterexample:\n\nx = [0x0, 0x11, 0x22, 0x33]\n\nTransaction trace:\nC.constructor()\nC.f()
// Info 1391: CHC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
