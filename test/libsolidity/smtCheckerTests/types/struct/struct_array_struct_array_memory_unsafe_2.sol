pragma abicoder               v2;

contract C {
	struct T {
		uint y;
		uint[] a;
	}
	struct S {
		uint x;
		T t;
		uint[] a;
		T[] ts;
	}
	function f(S memory s2) public pure {
		S memory s1;
		s1.x = 2;
		// Removed because current Spacer seg faults in cex generation.
		//assert(s1.x == s2.x);
		s1.t.y = 3;
		// Removed because current Spacer seg faults in cex generation.
		//assert(s1.t.y == s2.t.y);
		s1.a = new uint[](3);
		s1.a[2] = 4;
		// Removed because current Spacer seg faults in cex generation.
		//assert(s1.a[2] == s2.a[2]);
		s1.ts = new T[](6);
		s1.ts[3].y = 5;
		// Removed because current Spacer seg faults in cex generation.
		//assert(s1.ts[3].y == s2.ts[3].y);
		s1.ts[4].a = new uint[](6);
		s1.ts[4].a[5] = 6;
		require(s2.ts.length > 4);
		require(s2.ts[4].a.length > 6);
		assert(s1.ts[4].a[5] == s2.ts[4].a[5]);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (804-842): CHC: Assertion violation happens here.\nCounterexample:\n\ns2 = {x: 46, t: {y: 14, a: [12, 12, 12, 12, 12, 12, 33, 12, 12, 12, 12, 12, 12]}, a: [15, 15, 15, 15, 15, 15, 60, 15, 15, 15, 15, 15, 15, 15, 15, 15], ts}\ns1 = {x: 2, t: {y: 3, a: []}, a: [0, 0, 4], ts: [{y: 0, a: []}, {y: 0, a: []}, {y: 0, a: []}, {y: 5, a: []}, {y: 0, a: [0, 0, 0, 0, 0, 6]}, {y: 0, a: []}]}\n\nTransaction trace:\nC.constructor()\nC.f({x: 0, t: {y: 0, a: []}, a: [], ts: []})
// Info 1391: CHC: 10 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
