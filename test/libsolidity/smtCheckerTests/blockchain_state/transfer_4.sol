contract C {
	address payable recipient;

	function f() public payable {
		require(msg.value > 1);
		recipient.transfer(1);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 9207: (101-119): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
