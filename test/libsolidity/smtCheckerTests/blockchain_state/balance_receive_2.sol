contract C {
	uint x;
	bool once;
	constructor() payable {
		x = address(this).balance;
	}
	function f() public payable {
		require(!once);
		once = true;
		require(msg.value > 0);
		assert(address(this).balance > x); // should hold
		assert(address(this).balance > x + 10); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 4984: (266-272): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\nx = 115792089237316195423570985008687907853269984665640564039457584007913129639926, once = true\n\nTransaction trace:\nC.constructor(){ msg.value: 1323 }\nState: x = 115792089237316195423570985008687907853269984665640564039457584007913129639926, once = false\nC.f(){ msg.value: 6 }
// Warning 6328: (235-273): CHC: Assertion violation happens here.\nCounterexample:\nx = 0, once = true\n\nTransaction trace:\nC.constructor(){ msg.value: 0 }\nState: x = 0, once = false\nC.f(){ msg.value: 6 }
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
