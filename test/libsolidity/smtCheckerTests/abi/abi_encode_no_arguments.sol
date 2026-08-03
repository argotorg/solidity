contract C {
	function f() pure public {
		bytes memory res = abi.encode();
		assert(res.length == 0); // should hold
		assert(res.length > 0); // should fail
		res = abi.encodePacked();
		assert(res.length == 0); // should hold
		assert(res.length > 0); // should fail
		res = abi.encodeWithSelector(0);
		assert(res.length == 4); // should hold, but SMTChecker cannot know this yet
		res = abi.encodeWithSignature("");
		assert(res.length == 4); // should hold, but SMTChecker cannot know this yet
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (120-142): CHC: Assertion violation happens here.\nCounterexample:\n\nres = []\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (231-253): CHC: Assertion violation happens here.\nCounterexample:\n\nres = []\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (307-330): CHC: Assertion violation happens here.\nCounterexample:\n\nres = [0x14, 0x14, 0x14, 0x14, 0x14]\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (423-446): CHC: Assertion violation happens here.\nCounterexample:\n\nres = [0x19, 0x19, 0x19, 0x19, 0x19]\n\nTransaction trace:\nC.constructor()\nC.f()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
