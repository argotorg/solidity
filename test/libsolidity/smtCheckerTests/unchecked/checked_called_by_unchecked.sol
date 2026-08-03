contract C {
    function add(uint16 a, uint16 b) public pure returns (uint16) {
        return a + b; // can overflow
    }

    function f(uint16 a, uint16 b, uint16 c) public pure returns (uint16) {
        unchecked { return add(a, b) + c; } // add can still overflow, `+ c` can't
    }
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 4984: (96-101): CHC: Overflow (resulting value larger than 65535) happens here.\nCounterexample:\n\na = 1\nb = 65535\n = 0\n\nTransaction trace:\nC.constructor()\nC.add(1, 65535)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
