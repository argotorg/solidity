pragma abicoder               v2;

contract C
{
	uint[] array;
	function p() public {
		array.push();
	}
	function f(uint[] memory a, uint[] memory b) public {
		require(a.length > 0);
		require(b.length > 0);
		require(array.length > 0);
		array[0] = 42;
		a[0] = 2;
		// Access is safe but oob is reported due of aliasing.
		b[0] = 1;
		// Erasing knowledge about memory references should not
		// erase knowledge about state variables.
		// Removed because current Spacer seg faults.
		//assert(array[0] == 42);
		// Accesses are safe but oob is reported due of aliasing.
		assert(a[0] == 2);
		assert(b[0] == 1);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6368: (327-331): CHC: Out of bounds access happens here.\nCounterexample:\narray = [42]\nb = []\n\nTransaction trace:\nC.constructor()\nState: array = []\nC.p()\nState: array = [0]\nC.f(a, b) -- counterexample incomplete; parameter name used instead of value
// Warning 6368: (584-588): CHC: Out of bounds access happens here.\nCounterexample:\narray = [42]\na = []\n\nTransaction trace:\nC.constructor()\nState: array = []\nC.p()\nState: array = [0]\nC.f(a, b) -- counterexample incomplete; parameter name used instead of value
// Warning 6328: (577-594): CHC: Assertion violation happens here.\nCounterexample:\narray = [42]\n\nTransaction trace:\nC.constructor()\nState: array = []\nC.p()\nState: array = [0]\nC.f(a, b) -- counterexample incomplete; parameter name used instead of value
// Warning 6368: (605-609): CHC: Out of bounds access happens here.\nCounterexample:\narray = [42]\nb = []\n\nTransaction trace:\nC.constructor()\nState: array = []\nC.p()\nState: array = [0]\nC.f(a, b) -- counterexample incomplete; parameter name used instead of value
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
