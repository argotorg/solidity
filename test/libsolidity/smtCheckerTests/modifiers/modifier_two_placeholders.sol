contract C
{
	uint x;

	modifier m {
		require(x > 0);
		require(x < 10000);
		_;
		assert(x > 1);
		_;
		assert(x > 2);
		assert(x > 10);
	}

	function f() m public {
		x = x + 1;
	}

	function g(uint _x) public {
		x = _x;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (123-137): CHC: Assertion violation happens here.\nCounterexample:\nx = 3\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.g(1)\nState: x = 1\nC.f()
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
