contract C {
	struct S {
		int[] b;
	}
	S s;
	struct T {
		S[] s;
	}
	T t;
	function f() public {
		s.b.push();
		t.s.push();
		t.s[0].b.push();
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
