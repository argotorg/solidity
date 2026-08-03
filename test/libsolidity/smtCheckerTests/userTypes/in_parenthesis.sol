type MyInt is int;
contract C {
	function f() public pure returns (MyInt a) {
		a = MyInt.wrap(5);
		assert(MyInt.unwrap(a) == 5);
		assert(MyInt.unwrap(a) == 6); // should fail
	}

	function g() public pure {
		MyInt x = f();
		assert(MyInt.unwrap(x) == 5);
		assert(MyInt.unwrap(x) == 6); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (133-161): CHC: Assertion violation happens here.\nCounterexample:\n\na = 5\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (261-289): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nC.g()\n    C.f() -- internal call
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
