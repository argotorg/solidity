contract C {
	int public x;

	function f() public view {
		int y = 42;
		bool success = false;
		try this.x() returns (int v) {
			y = v;
			try this.x() returns (int w) {
				success = true;
				y = w;
			}
			catch {}
		} catch {}
		assert(!success || y == x); // should hold
		assert(y == 42); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (280-295): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\ny = 0\nsuccess = false\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
