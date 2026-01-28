contract C {
    uint8 constant N = 255;

    function f() public pure returns (uint8) {
        return N + 1;
    }
}
// ====
// SMTEngine: chc
// ----
// Warning 4984: (104-109): CHC: Overflow (resulting value larger than 255) happens here.\nCounterexample:\nN = 255\n = 0\n\nTransaction trace:\nC.constructor()\nState: N = 255\nC.f()
