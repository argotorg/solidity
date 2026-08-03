type MyInt is int;
contract C {
	function f() public pure returns (MyInt a, int b) {
		(MyInt).wrap;
		a = (MyInt).wrap(5);
		(MyInt).unwrap;
		b = (MyInt).unwrap((MyInt).wrap(10));
	}

	function g() public pure {
		(MyInt x, int y) = f();
		assert(MyInt.unwrap(x) == 5);
		assert(MyInt.unwrap(x) == 6); // should fail
		assert(y == 10);
		assert(y == 11); // should fail
	}

}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6133: (87-99): Statement has no effect.
// Warning 6133: (126-140): Statement has no effect.
// Warning 6328: (274-302): CHC: Assertion violation happens here.\nCounterexample:\n\ny = 10\n\nTransaction trace:\nC.constructor()\nC.g()\n    C.f() -- internal call
// Warning 6328: (340-355): CHC: Assertion violation happens here.\nCounterexample:\n\ny = 10\n\nTransaction trace:\nC.constructor()\nC.g()\n    C.f() -- internal call
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
