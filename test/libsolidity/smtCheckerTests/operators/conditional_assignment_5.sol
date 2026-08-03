abstract contract D {
    function d() public virtual ;
}

contract C {
    bool a;
    uint x;
    D d;
    function g() public returns (uint) {
        x = 2;
        d.d();
        return x;
    }
    function f() public {
        x = 1;
        uint y = g();
        assert(x == 2 || x == 1);
    }
    function h() public {
        x = 3;
    }
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 2072: (249-255): Unused local variable.
// Warning 6328: (271-295): CHC: Assertion violation happens here.\nCounterexample:\na = false, x = 3, d = 0\ny = 3\n\nTransaction trace:\nC.constructor()\nState: a = false, x = 0, d = 0\nC.f()\n    C.g() -- internal call\n        d.d() -- untrusted external call, synthesized as:\n            C.h() -- reentrant call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
