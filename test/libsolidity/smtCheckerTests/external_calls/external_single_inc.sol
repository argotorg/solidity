abstract contract D {
	function d() external virtual;
}

contract C {
	uint x;
	uint y;
	D d;

	function inc() public {
		if (y == 1)
			x = 1;
		if (x == 0)
			y = 1;
	}

	function f() public {
		uint oldX = x;
		d.d();
		assert(oldX == x);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (223-240): CHC: Assertion violation happens here.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
