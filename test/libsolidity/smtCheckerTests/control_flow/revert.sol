contract C {
	function f() pure public {
		revert();
		// This is not reachable.
		assert(false);
	}

	function g() pure public {
		revert("revert message");
		// This is not reachable.
		assert(false);
	}

	function h(bool b) pure public {
		if (b)
			revert();
		assert(!b);
	}

	// Check that arguments are evaluated.
	bool x = false;
	function m() view internal returns (string memory) {
		assert(x != true);
	}
	function i() public {
		x = true;
		revert(m());
	}
}
// ====
// SMTEngine: all
// ----
// Warning 5740: (83-96): Unreachable code.
// Warning 5740: (188-201): Unreachable code.
// Warning 6321: (375-388): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
// Warning 6328: (394-411): CHC: Assertion violation happens here.\nCounterexample:\nx = true\n\nTransaction trace:\nC.constructor()\nState: x = false\nC.i()\n    C.m() -- internal call
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
