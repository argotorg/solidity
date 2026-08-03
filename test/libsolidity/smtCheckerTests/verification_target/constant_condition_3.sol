// a plain literal constant is fine
contract C {
    function f(uint) public pure {
        if (true) { revert(); }
    }
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
