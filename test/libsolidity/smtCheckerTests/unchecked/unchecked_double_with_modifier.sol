contract C {

	modifier m() {
		unchecked{}
		_;
	}

	function t() m internal pure {}

	function f() public pure {
		unchecked { t(); }
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
