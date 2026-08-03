contract test {
    function f() public pure returns (bool) {
        int256 x = -2**255;
        unchecked { assert(-x == x); }
        assert(-x == x);
        return true;
    }
}
// ====
// SMTEngine: all
// ----
// Warning 4984: (117-119): CHC: Overflow (resulting value larger than 2**255 - 1) happens here.\nCounterexample:\n\n = false\nx = (- 57896044618658097711785492504343953926634992332820282019728792003956564819968)\n\nTransaction trace:\ntest.constructor()\ntest.f()
// Warning 6328: (110-125): CHC: Assertion violation happens here.\nCounterexample:\n\n = false\nx = (- 57896044618658097711785492504343953926634992332820282019728792003956564819968)\n\nTransaction trace:\ntest.constructor()\ntest.f()
// Info 1391: CHC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
