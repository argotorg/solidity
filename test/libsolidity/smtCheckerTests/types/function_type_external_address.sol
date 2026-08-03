contract C {
    function f(address a, function(uint) external g) internal pure {
		address b = g.address;
		assert(a == b);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 7650: (96-105): Assertion checker does not yet support this expression.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
