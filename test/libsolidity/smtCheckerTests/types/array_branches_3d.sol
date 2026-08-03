contract C
{
	uint[][][] c;
	constructor() {
		c.push();
		c[0].push();
		c[0][0].push();
	}
	function f(bool b) public {
		c[0][0][0] = 0;
		if (b)
			c[0][0][0] = 1;
		assert(c[0][0][0] < 2);
	}
}
// ====
// SMTEngine: all
// SMTTargets: assert
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
