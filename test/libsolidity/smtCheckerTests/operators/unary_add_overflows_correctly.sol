contract C {
	uint8 x = 254;

	function inc_pre() public {
		++x;
	}

	function check() view public {
		uint y = x;
		assert(y < 256);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 4984: (61-64): CHC: Overflow (resulting value larger than 255) happens here.\nCounterexample:\nx = 255\n\nTransaction trace:\nC.constructor()\nState: x = 254\nC.inc_pre()\nState: x = 255\nC.inc_pre()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
