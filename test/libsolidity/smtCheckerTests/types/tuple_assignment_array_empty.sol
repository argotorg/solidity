contract C
{
	uint[] a;
	function f(uint x) public {
		a.push(x);
	}
	function g(uint x, uint y) public {
		require(x < a.length);
		require(y < a.length);
		require(x != y);
		(, a[y]) = (2, 4);
		assert(a[x] == 2);
		assert(a[y] == 4);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// SMTTargets: assert
// ----
// Warning 6328: (198-215): CHC: Assertion violation happens here.\nCounterexample:\na = [4, 6531]\nx = 1\ny = 0\n\nTransaction trace:\nC.constructor()\nState: a = []\nC.f(221)\nState: a = [221]\nC.f(6531)\nState: a = [221, 6531]\nC.g(1, 0)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
