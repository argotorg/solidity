contract C {
	struct S {
		string s;
		bytes b;
	}

	S public m;

	constructor() {
		m.s = "foo";
		m.b = "bar";
	}

	function f() public view {
		(string memory s, bytes memory b) = this.m();
		assert(keccak256(bytes(s)) == keccak256(bytes(m.s))); // should hold
		assert(b[0] == m.b[0]); // should hold
		assert(b[0] == "t"); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (307-326): CHC: Assertion violation happens here.\nCounterexample:\nm = {s: [0x66, 0x6f, 0x6f], b: [0x62, 0x61, 0x72]}\ns = [0x66, 0x6f, 0x6f]\nb = [0x62, 0x61, 0x72]\n\nTransaction trace:\nC.constructor()\nState: m = {s: [0x66, 0x6f, 0x6f], b: [0x62, 0x61, 0x72]}\nC.f()
// Info 1391: CHC: 5 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
