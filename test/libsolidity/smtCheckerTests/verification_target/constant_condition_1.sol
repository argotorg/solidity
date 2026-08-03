contract C {
    function f(uint x) public pure {
        if (x >= 0) { revert(); }
    }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (62-68): BMC: Condition is always true.
