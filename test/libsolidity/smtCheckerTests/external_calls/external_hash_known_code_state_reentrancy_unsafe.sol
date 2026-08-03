contract State {
	uint x;
	C c;
	function f() public returns (uint) {
		c.setOwner(address(0));
		return c.g();
	}
}

contract C {
	address owner;
	uint y;
	State s;

	constructor() {
		owner = msg.sender;
	}

	function setOwner(address _owner) public {
		owner = _owner;
	}

	function f() public {
		address prevOwner = owner;
		uint z = s.f();
		assert(z == y);
		assert(prevOwner == owner);
	}

	function g() public view returns (uint) {
		return y;
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// SMTIgnoreOS: macos
// ----
// Warning 6328: (348-362): CHC: Assertion violation happens here.\nCounterexample:\nowner = 0x0, y = 0, s = 0\nprevOwner = 0x0\nz = 1\n\nTransaction trace:\nC.constructor(){ msg.sender: 0x0 }\nState: owner = 0x0, y = 0, s = 0\nC.f()\n    s.f() -- untrusted external call
// Warning 6328: (366-392): CHC: Assertion violation happens here.\nCounterexample:\nowner = 0x0, y = 0, s = 0\nprevOwner = 0x01\nz = 1\n\nTransaction trace:\nC.constructor(){ msg.sender: 0x01 }\nState: owner = 0x01, y = 0, s = 0\nC.f()\n    s.f() -- untrusted external call, synthesized as:\n        C.setOwner(0x0) -- reentrant call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
