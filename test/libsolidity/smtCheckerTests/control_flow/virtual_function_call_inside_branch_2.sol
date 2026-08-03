contract A {
    function f() internal virtual {
        v();
    }
    function v() internal virtual {
    }
}

contract B is A {
    function f() internal virtual override {
        super.f();
    }
}

contract C is B {
    function v() internal override {
        if (0==1)
            f();
    }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (271-275): BMC: Condition is always false.
