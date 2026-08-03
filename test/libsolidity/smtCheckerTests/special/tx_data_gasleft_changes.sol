contract C {
	uint gleft;

	function f() public payable {
		gleft = gasleft();

		fi();

		assert(gleft == gasleft());
		assert(gleft >= gasleft());
	}

	function fi() internal view {
		assert(gleft == gasleft());
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (91-117): CHC: Assertion violation happens here.\nCounterexample:\ngleft = 1\n\nTransaction trace:\nC.constructor()\nState: gleft = 0\nC.f(){ msg.value: 19 }\n    C.fi() -- internal call
// Warning 6328: (186-212): CHC: Assertion violation happens here.\nCounterexample:\ngleft = 1\n\nTransaction trace:\nC.constructor()\nState: gleft = 0\nC.f(){ msg.value: 19 }\n    C.fi() -- internal call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
