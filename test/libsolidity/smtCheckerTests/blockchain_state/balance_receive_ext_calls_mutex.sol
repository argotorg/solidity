interface I {
	function ext() external;
}

contract C {
	bool lock;
	modifier mutex {
		require(!lock);
		lock = true;
		_;
		lock = false;
	}
	function f(I _i) public mutex {
		uint x = address(this).balance;
		_i.ext();
		assert(address(this).balance == x); // should hold
		assert(address(this).balance < x); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (277-310): CHC: Assertion violation happens here.\nCounterexample:\nlock = true\n_i = 0\nx = 38\n\nTransaction trace:\nC.constructor()\nState: lock = false\nC.f(0)\n    _i.ext() -- untrusted external call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
