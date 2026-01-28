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
// Warning 6328: (198-215): CHC: Assertion violation happens here.\nCounterexample:\na = [3212, 4]\nx = 0\ny = 1\n\nTransaction trace:\nC.constructor()\nState: a = []\nC.f(3212)\nState: a = [3212]\nC.f(1573)\nState: a = [3212, 1573]\nC.g(0, 1)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
