contract C {
    function f() public pure {
        uint v = 7;
        v ^= 3;
        assert(v != 4); // fails, as 7 ^ 3 = 4

        uint c = 0;
        c ^= v;
        assert(c == 4);

        uint16 x = 0xff;
        uint16 y = 0xffff;
        y ^= x;
        assert(y == 0xff); // fails
        assert(y == 0xff00);

        y = 0xf1;
        x = 0xff00;
        y ^= x | y;
        assert(y == 0xffff); // fails
        assert(x == 0xff00);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (88-102): CHC: Assertion violation happens here.\nCounterexample:\n\nv = 4\nc = 0\nx = 0\ny = 0\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (265-282): CHC: Assertion violation happens here.\nCounterexample:\n\nv = 4\nc = 4\nx = 255\ny = 65280\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (389-408): CHC: Assertion violation happens here.\nCounterexample:\n\nv = 4\nc = 4\nx = 65280\ny = 65280\n\nTransaction trace:\nC.constructor()\nC.f()
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
