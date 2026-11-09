contract C {
	function h() external pure {}

	function f(uint8 x) public view returns (bytes memory b) {
		b = abi.encodeCall(this.h, ());
		assert(uint256(x) + 1 > uint256(x)); // should hold
	}
}
// ====
// SMTEngine: all
// SMTShowProvedSafe: yes
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 9576: (148-162): CHC: Overflow (resulting value larger than 2**256 - 1) check is safe!
// Info 9576: (141-176): CHC: Assertion violation check is safe!
