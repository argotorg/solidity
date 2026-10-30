contract C {
    function f(uint x) public pure {
        if (x >= 10) { if (x < 10) { revert(); } }
    }
}
// ====
// SMTEngine: all
// ----
