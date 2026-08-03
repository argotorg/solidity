contract C {
	struct S {
		uint8 x;
	}

	S s;

	constructor() {
		s.x = 254;
	}

	function inc_pre() public {
		++s.x;
	}

	function check() view public {
		uint y = s.x;
		assert(y < 256);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 4984: (112-117): CHC: Overflow (resulting value larger than 255) happens here.\nCounterexample:\ns = {x: 255}\n\nTransaction trace:\nC.constructor()\nState: s = {x: 254}\nC.inc_pre()\nState: s = {x: 255}\nC.inc_pre()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
