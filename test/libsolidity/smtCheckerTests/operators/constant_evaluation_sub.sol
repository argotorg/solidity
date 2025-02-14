contract C {
    uint256 public constant B = 1;

    function f() public pure returns (uint256) {
        return B - 112;
    }
}
// ====
// SMTEngine: chc
// ----
// Warning 3944: (113-120): CHC: Underflow (resulting value less than 0) happens here.\nCounterexample:\nB = 1\n = 0\n\nTransaction trace:\nC.constructor()\nState: B = 1\nC.f()
