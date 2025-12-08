contract C {
	function f(address payable a) public {
		a.transfer(200);
	}
}
// ====
// SMTEngine: bmc
// ----
// Warning 9207: (55-65): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 1236: (55-70): BMC: Insufficient funds happens here.
