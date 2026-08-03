contract BaseBase {
	uint x;
	function init(uint a, uint b) public virtual {
		x = a;
	}
}
contract Base is BaseBase {
	function init(uint a, uint b) public override {
	}
}
contract Child is Base {
	function bInit(uint c, uint d) public {
		BaseBase.init(c, d);
		assert(x == c);
		assert(x == d); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 5667: (52-58): Unused function parameter. Remove or comment out the variable name to silence this warning.
// Warning 6328: (282-296): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\nc = 1\nd = 0\n\nTransaction trace:\nChild.constructor()\nState: x = 0\nBase.init(0, 0)\nState: x = 0\nChild.bInit(1, 0)\n    BaseBase.init(1, 0) -- internal call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
