library L {
    struct Nested { uint y; }
    function c(function(Nested memory) external returns (uint)[] storage) external pure {}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
