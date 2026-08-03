pragma abicoder               v2;

contract C {
	uint[][] arr;
	uint[][] arr2;
	constructor() {
		arr.push();
		arr.push();
		arr2.push();
		arr2.push();
	}
	function f() public view {
		assert(arr2[0].length == arr[0].length);
		assert(arr2.length == arr.length);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreOS: macos
// ----
// Info 1391: CHC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
