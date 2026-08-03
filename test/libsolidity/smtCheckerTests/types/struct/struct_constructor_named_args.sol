contract C {

	struct S {
		uint x;
	}

	struct T {
		S s;
		uint y;
	}

	function test() pure public {
		S memory inner = S({x: 43});
		T memory outer = T({y: 512, s: inner});
		assert(outer.y == 512);
		assert(outer.s.x == 43);
		assert(outer.s.x == 42);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: no
// ----
// Warning 6328: (232-255): CHC: Assertion violation happens here.\nCounterexample:\n\ninner = {x: 43}\nouter = {s: {x: 43}, y: 512}\n\nTransaction trace:\nC.constructor()\nC.test()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
