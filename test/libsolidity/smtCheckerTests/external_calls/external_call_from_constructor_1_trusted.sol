contract State {
	function f(uint _x) public pure returns (uint) {
		assert(_x < 100); // should hold when analyzing only contract C (can fail only when analyzing State as standalone contract)
		return _x;
	}
}
contract C {
	State s;
	uint z = s.f(2);

	function f() public view {
		assert(z == 2); // should hold in trusted mode
	}
}
// ====
// SMTContract: C
// SMTEngine: all
// SMTExtCalls: trusted
// SMTIgnoreInv: yes
// ----
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
