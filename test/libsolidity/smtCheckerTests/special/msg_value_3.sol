contract C {
	bool lock = true;
	function f() public {
		lock = false;
		g();
		lock = true;
	}
	function g() public payable {
		require(lock == false);
		assert(msg.value == 0);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
