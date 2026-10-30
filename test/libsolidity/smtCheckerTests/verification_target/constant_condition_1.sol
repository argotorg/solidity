contract C {
    function f(uint x) public pure {
        if (x >= 0) { revert(); }
    }
}
// ====
// SMTEngine: all
// ----
