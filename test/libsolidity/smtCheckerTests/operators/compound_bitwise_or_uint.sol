contract C {
    function f() public pure {
        uint v = 7;
        v |= 3;
        assert(v != 7); // fails, as 7 | 3 = 7

        uint c = 0;
        c |= v;
        assert(c == 7);

        uint16 x = 0xff;
        uint16 y = 0xffff;
        y |= x;
        assert(y == 0xff); // fails
        assert(y == 0xffff);

        y = 0xf1ff;
        x = 0xff00;
        x |= y & x;
        assert(y == 0xffff); // fails
        assert(x == 0xff00);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (88-102): CHC: Assertion violation happens here.\nCounterexample:\n\nv = 7\nc = 0\nx = 0\ny = 0\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (265-282): CHC: Assertion violation happens here.\nCounterexample:\n\nv = 7\nc = 7\nx = 255\ny = 65535\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (391-410): CHC: Assertion violation happens here.\nCounterexample:\n\nv = 7\nc = 7\nx = 65280\ny = 61951\n\nTransaction trace:\nC.constructor()\nC.f()
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
