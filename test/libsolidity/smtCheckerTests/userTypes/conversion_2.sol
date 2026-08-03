pragma abicoder v2;

type MyUInt8 is uint8;
type MyInt8 is int8;
type MyUInt16 is uint16;

contract C {
	function h(MyUInt8 a) internal pure returns (MyInt8) {
		return MyInt8.wrap(int8(MyUInt8.unwrap(a)));
	}
	function i(MyUInt8 a) internal pure returns(MyUInt16) {
		return MyUInt16.wrap(MyUInt8.unwrap(a));
	}

	function r() public pure {
		assert(MyInt8.unwrap(h(MyUInt8.wrap(1))) == 1);
		assert(MyInt8.unwrap(h(MyUInt8.wrap(2))) == 2);
		assert(MyInt8.unwrap(h(MyUInt8.wrap(255))) == -1);
		assert(MyInt8.unwrap(h(MyUInt8.wrap(255))) == 1); // should fail
	}

	function s() public pure {
		assert(MyUInt16.unwrap(i(MyUInt8.wrap(250))) == 250);
		assert(MyUInt16.unwrap(i(MyUInt8.wrap(250))) == 0); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (497-545): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nC.r()\n    C.h(1) -- internal call\n    C.h(2) -- internal call\n    C.h(255) -- internal call\n    C.h(255) -- internal call
// Warning 6328: (652-702): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nC.s()\n    C.i(250) -- internal call\n    C.i(250) -- internal call
// Info 1391: CHC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
