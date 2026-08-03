contract C {
	uint x;

	function f() public {
		if (x == 0)
			x = 1;
	}

	function g() public {
		if (x == 1)
			x = 2;
	}

	function h() public {
		if (x == 2)
			x = 0;
	}

	function j() public {
		if (x < 2)
			x = 100;
	}

	// Fails due to j.
	function i() public view {
		// Disabled because Spacer 4.8.9 seg faults.
		//assert(x < 2);
	}
}
// ====
// SMTEngine: all
// SMTSolvers: z3
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
