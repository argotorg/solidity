contract C {
	function g() external {
		f();
	}

	function h() external payable {
		f();
	}

	function f() internal {
		require(msg.value == 0);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
