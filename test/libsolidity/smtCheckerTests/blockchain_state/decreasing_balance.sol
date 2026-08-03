contract C {
	uint t;
	constructor() {
		t = address(this).balance;
	}
	function f(address payable a, uint x) public {
		require(address(this).balance >= x);
		a.transfer(x);
	}
	function inv() public view {
		// If only looking at `f`, it looks like this.balance always decreases.
		// However, the edge case of a contract `selfdestruct` sending its remaining balance
		// to this contract should make the claim false (since there's no fallback/receive here).
		// Removed because current Spacer seg faults in cex generation.
		//assert(address(this).balance == t);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 9207: (160-170): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
