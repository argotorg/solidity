contract C
{
	mapping (uint => uint) a;
	mapping (uint => uint) b;

	function f(uint x) public {
		a[1] = x;
		b[1] = x;
		a[1] = 2;
		mapping (uint => uint) storage c = a;
		assert(c[1] == 2);
		// False negative! Needs aliasing.
		assert(a[1] == b[1]);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (233-253): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 223\n\nTransaction trace:\nC.constructor()\nC.f(223)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
