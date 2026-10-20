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
