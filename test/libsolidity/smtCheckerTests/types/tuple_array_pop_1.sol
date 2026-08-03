contract C {
	int[] a;
	function f() public { (a).pop();}
}
// ====
// SMTEngine: all
// ----
// Warning 2529: (46-55): CHC: Empty array "pop" happens here.\nCounterexample:\na = []\n\nTransaction trace:\nC.constructor()\nState: a = []\nC.f()
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
