contract C {
	struct S {
		string a;
		uint256 y;
	}
	S public s;
	function g() public view returns (uint256) {
		this.s();
	}
}
// ====
// EVMVersion: <=spuriousDragon
// SMTEngine: all
// ----
// Warning 6321: (101-108): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
