contract C {
	struct S {
		uint[][] arr;
	}
	S s1;
	S s2;
	constructor() {
		s1.arr.push();
		s2.arr.push();
		s1.arr[0].push();
		s1.arr[0].push();
		s1.arr[0].push();
		s2.arr[0].push();
		s2.arr[0].push();
		s2.arr[0].push();
	}
	function f() public view {
		assert(s1.arr[0].length == s2.arr[0].length);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreOS: macos
// ----
// Info 1391: CHC: 9 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
