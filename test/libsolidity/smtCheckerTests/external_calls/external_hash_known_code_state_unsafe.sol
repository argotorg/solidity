contract State {
	uint x;
	function f() public returns (uint) {
		if (x == 0) x = 1;
		else if (x == 1) x = 2;
		else if (x == 2) x = 0;
		return x;
	}
}

contract C {
	address owner;
	uint y;
	uint z;
	State s;

	constructor() {
		owner = msg.sender;
	}

	function setOwner(address _owner) public {
		owner = _owner;
	}

	function f() public {
		address prevOwner = owner;
		y = s.f();
		z = s.f();
		assert(prevOwner == owner);
	}

	function inv() public view {
		// This is safe but external calls do not yet support the state
		// of the called contract.
		assert(owner == address(0) || y != z);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (402-428): CHC: Assertion violation happens here.\nCounterexample:\nowner = 0x0, y = 0, z = 0, s = 0\nprevOwner = 0x01\n\nTransaction trace:\nC.constructor(){ msg.sender: 0x01 }\nState: owner = 0x01, y = 0, z = 0, s = 0\nC.f()\n    s.f() -- untrusted external call, synthesized as:\n        C.setOwner(0x0) -- reentrant call\n    s.f() -- untrusted external call
// Warning 6328: (561-598): CHC: Assertion violation happens here.\nCounterexample:\nowner = 0x01, y = 0, z = 0, s = 0\n\nTransaction trace:\nC.constructor(){ msg.sender: 0x01 }\nState: owner = 0x01, y = 0, z = 0, s = 0\nC.inv()
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
