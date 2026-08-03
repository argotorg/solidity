contract C {
    struct Nested { uint y; }
    // ensure that we consider array of function pointers as reference type
    function b(function(Nested memory) external returns (uint)[] storage) internal pure {}
    function c(function(Nested memory) external returns (uint)[] memory) public pure {}
    function d(function(Nested memory) external returns (uint)[] calldata) external pure {}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
