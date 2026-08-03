contract Crypto {
	function hash(bytes32) external pure returns (bytes32) {
		return bytes32(0);
	}
}

contract C {
	address owner;
	bytes32 sig_1;
	bytes32 sig_2;
	Crypto d;

	constructor() {
		owner = msg.sender;
	}

	function f1(bytes32 _msg) public {
		address prevOwner = owner;
		sig_1 = d.hash(_msg);
		sig_2 = d.hash(_msg);
		assert(prevOwner == owner);
	}

	function inv() public view {
		assert(sig_1 == sig_2);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (398-420): CHC: Assertion violation happens here.\nCounterexample:\nowner = 0x0, sig_1 = 0x01, sig_2 = 0x0, d = 0\n\nTransaction trace:\nC.constructor(){ msg.sender: 0x0 }\nState: owner = 0x0, sig_1 = 0x0, sig_2 = 0x0, d = 0\nC.f1(0x0)\n    d.hash(_msg) -- untrusted external call\n    d.hash(_msg) -- untrusted external call\nState: owner = 0x0, sig_1 = 0x01, sig_2 = 0x0, d = 0\nC.inv()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
