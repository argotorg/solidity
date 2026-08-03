contract C {
	struct S {
		uint x;
	}

	S s;

	function f() public {
		s.x = 42;
		S memory sm = s;
		assert(sm.x == 42); // should hold
		uint256 i = 7;
		assembly {
			mstore(sm, i)
		}
		assert(sm.x == 42); // should fail
		assert(sm.x == 7); // should hold, but the analysis cannot know this yet
		assert(s.x == 42); // should hold, storage not changed by the assembly
		assert(i == 7); // should hold, not changed by the assembly
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 7737: (156-187): Inline assembly may cause SMTChecker to produce spurious warnings (false positives).
// Warning 6328: (190-208): CHC: Assertion violation happens here.\nCounterexample:\ns = {x: 42}\nsm = {x: 23}\ni = 7\n\nTransaction trace:\nC.constructor()\nState: s = {x: 0}\nC.f()
// Warning 6328: (227-244): CHC: Assertion violation happens here.\nCounterexample:\ns = {x: 42}\nsm = {x: 20627}\ni = 7\n\nTransaction trace:\nC.constructor()\nState: s = {x: 0}\nC.f()
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
