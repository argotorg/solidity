abstract contract E18_Base {
    function g() public pure returns (bytes2) {
        return hex"ffff";
    }
}

contract C is E18_Base {
    function f() public view {
        this.g();
        assert(false);
    }
}
// ====
// SMTEngine: chc
// SMTIgnoreCex: yes
// SMTIgnoreInv: yes
// ----
// Warning 6328: (194-207): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nC.f()\n    E18_Base.g() -- trusted external call
