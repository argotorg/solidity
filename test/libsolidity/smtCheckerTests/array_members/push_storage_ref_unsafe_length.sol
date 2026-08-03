contract C {
	uint[][] a;
	uint[][][] c;
	uint[] d;
	constructor() {
		c.push().push().push();
		d.push(); d.push();
	}
	function f() public {
		a.push();
		uint[] storage b = a[0];
		// Access is safe but oob reported due to aliasing.
		c[0][0][0] = 12;
		// Access is safe but oob reported due to aliasing.
		d[1] = 7;
		b.push(8);
		assert(a[0].length == 0);
		// Safe but knowledge about `c` is erased because `b` could be pointing to `c[x][y]`.
		// Access is safe but oob reported due to aliasing.
		assert(c[0][0][0] == 12);
		// Safe but knowledge about `d` is erased because `b` could be pointing to `d`.
		// Removed assertion because current Spacer seg faults in cex generation.
		//assert(d[1] == 7);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreOS: macos
// ----
// Warning 6368: (238-242): CHC: Out of bounds access happens here.
// Warning 6368: (238-245): CHC: Out of bounds access happens here.
// Warning 6368: (238-248): CHC: Out of bounds access happens here.
// Warning 6368: (311-315): CHC: Out of bounds access happens here.
// Warning 6368: (343-347): CHC: Out of bounds access happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nState: a = [], c = [[[0]]], d = [0, 0]\nC.f()
// Warning 6328: (336-360): CHC: Assertion violation happens here.\nCounterexample:\n\nb = [47, 47, 47, 47, 47, 93, 47, 47, 47, 47, 50, 47, 47, 47, 47, 47, 91, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 8]\n\nTransaction trace:\nC.constructor()\nState: a = [], c = [[[0]]], d = [0, 0]\nC.f()
// Warning 6368: (513-517): CHC: Out of bounds access happens here.\nCounterexample:\nc = []\nb = [49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 107, 49, 49, 49, 49, 106, 49, 97, 49, 49, 49, 49, 49, 49, 49, 49, 8]\n\nTransaction trace:\nC.constructor()\nState: a = [], c = [[[0]]], d = [0, 0]\nC.f()
// Warning 6368: (513-520): CHC: Out of bounds access happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nState: a = [], c = [[[0]]], d = [0, 0]\nC.f()
// Warning 6368: (513-523): CHC: Out of bounds access happens here.\nCounterexample:\n\nb = [68, 68, 122, 68, 68, 105, 68, 68, 68, 68, 68, 125, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 116, 8]\n\nTransaction trace:\nC.constructor()\nState: a = [], c = [[[0]]], d = [0, 0]\nC.f()
// Warning 6328: (506-530): CHC: Assertion violation happens here.\nCounterexample:\n\nb = [6, 6, 6, 6, 6, 6, 6, 111, 6, 6, 6, 6, 112, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 71, 6, 6, 110, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 72, 6, 8]\n\nTransaction trace:\nC.constructor()\nState: a = [], c = [[[0]]], d = [0, 0]\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
