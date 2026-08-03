abstract contract D {
    function d() public virtual ;
}

contract C {
    bool a;
    uint x;
    D d;
    function g() public returns (uint) {
        x = 2;
        return x;
    }
    function f(bool b) public {
        x = 1;
        uint y = b ? g() : 3;
        assert(x == 2 || x == 1);
    }
    function h() public {
        x = 3;
    }
}
// ====
// SMTEngine: all
// ----
// Warning 2072: (240-246): Unused local variable.
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
