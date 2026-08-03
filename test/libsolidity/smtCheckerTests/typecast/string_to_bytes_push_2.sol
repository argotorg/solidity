contract C {
	string x;

	function s() public {
		x = "abc";
		((bytes(((x))))).push("a");
		assert(bytes(x).length == 4); // should hold
		assert(bytes(x).length == 3); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (140-168): CHC: Assertion violation happens here.\nCounterexample:\nx = [0x61, 0x62, 0x63, 0x61]\n\nTransaction trace:\nC.constructor()\nState: x = []\nC.s()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
