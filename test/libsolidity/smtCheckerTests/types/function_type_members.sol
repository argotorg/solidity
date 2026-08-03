contract C {
    function f(function(uint) external payable g) internal {
		g.selector;
		g{gas: 2, value: 3}(4);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 7650: (76-86): Assertion checker does not yet support this expression.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
