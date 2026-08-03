contract C {
	uint256 public z;

	function f() public {
		z = 42;
		uint i = 32;
		assembly {
			function f() {
				sstore(z.slot, 7)
			}
			f()
		}
		assert(z == 42); // should fail
		assert(z == 7); // should hold, but the analysis cannot know this yet
		assert(i == 32); // should hold, not changed by the assembly
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 7737: (83-149): Inline assembly may cause SMTChecker to produce spurious warnings (false positives).
// Warning 6328: (152-167): CHC: Assertion violation happens here.\nCounterexample:\nz = 43\ni = 32\n\nTransaction trace:\nC.constructor()\nState: z = 0\nC.f()
// Warning 6328: (186-200): CHC: Assertion violation happens here.\nCounterexample:\nz = 0\ni = 32\n\nTransaction trace:\nC.constructor()\nState: z = 0\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
