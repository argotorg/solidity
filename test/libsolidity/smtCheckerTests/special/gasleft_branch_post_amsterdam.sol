contract C
{
	function f() public view {
		uint g = gasleft();
		uint flag = gasleft() > g ? 1 : 0;
		assert(flag == 0);
	}
}
// ====
// EVMVersion: >=amsterdam
// SMTEngine: all
// ----
// Warning 6328: (102-119): CHC: Assertion violation happens here.\nCounterexample:\n\ng = 0\nflag = 1\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
