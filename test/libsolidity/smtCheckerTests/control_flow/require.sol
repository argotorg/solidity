contract C {
	function f() pure public {
		require(false);
		// This is not reachable.
		assert(false);
	}

	function g() pure public {
		require(false, "require message");
		// This is not reachable.
		assert(false);
	}

	function h(bool b) pure public {
		if (b)
			require(false);
		assert(!b);
	}

	// Check that arguments are evaluated.
	bool x = false;
	function m() view internal returns (string memory) {
		assert(x != true);
	}
	function i() public {
		x = true;
		require(false, m());
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6321: (396-409): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
// Warning 6328: (415-432): CHC: Assertion violation happens here.\nCounterexample:\nx = true\n\nTransaction trace:\nC.constructor()\nState: x = false\nC.i()\n    C.m() -- internal call
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
