abstract contract D {
	function d() virtual public;
}

contract C {
	bytes data;

	bytes32 kec;

	constructor(bytes memory _data) {
		data = _data;

		kec = keccak256(data);
	}

	function check(bytes memory _data) public view {
		bytes32 _kec = keccak256(data);
		assert(_kec == kec); // should hold
		assert(kec == keccak256(_data)); // should fail
	}

	function ext(D d) public {
		d.d();
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// SMTIgnoreInv: yes
// ----
// Warning 6328: (302-333): CHC: Assertion violation happens here.\nCounterexample:\nkec = 0x2298\n_kec = 0x2298\n\nTransaction trace:\nC.constructor(_data) -- counterexample incomplete; parameter name used instead of value\nState: kec = 0x2298\nC.check(_data) -- counterexample incomplete; parameter name used instead of value
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
