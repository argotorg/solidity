contract C {
    function f() public returns (uint) {
        try this.f() {
        } catch Error(string memory) {
			g();
		}
	}
	function g() public pure returns (address) {
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6321: (46-50): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
