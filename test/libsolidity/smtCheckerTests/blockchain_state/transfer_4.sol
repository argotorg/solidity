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
