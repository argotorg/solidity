contract C {
	int x;

	function g() public  {
		x = 42;
	}

	function f() public {
		x = 1;
		bool success = false;
		try this.g() {
			success = true;
			assert(x == 42); // should hold
		} catch Error (string memory /*reason*/) {
			assert(x == 1); // should hold
		} catch (bytes memory /*reason*/) {
			assert(x == 1); // should hold
		}
		assert((success && x == 42) || (!success && x == 1)); // should hold
		assert(success); // can fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (415-430): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\nsuccess = false\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f()
// Info 1391: CHC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
