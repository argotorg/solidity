contract C {
    function f(uint x) public pure {
        if (x >= 10) { if (x < 10) { revert(); } }
    }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (77-83): BMC: Condition is always false.
