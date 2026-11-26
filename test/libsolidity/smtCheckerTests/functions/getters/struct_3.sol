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
		S memory r = this.m();
		assert(keccak256(bytes(r.s)) == keccak256(bytes(m.s))); // should hold
		assert(r.b[0] == m.b[0]); // should hold
		assert(r.b[0] == "t"); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (288-309): CHC: Assertion violation happens here.\nCounterexample:\nm = {s: [0x66, 0x6f, 0x6f], b: [0x62, 0x61, 0x72]}\nr = {s: [0x66, 0x6f, 0x6f], b: [0x62, 0x61, 0x72]}\n\nTransaction trace:\nC.constructor()\nState: m = {s: [0x66, 0x6f, 0x6f], b: [0x62, 0x61, 0x72]}\nC.f()
// Info 1391: CHC: 5 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
