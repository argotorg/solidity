contract C {
	address payable recipient;
	uint amount;

	function shouldHold() public {
		uint tempAmount = address(this).balance;
		recipient.transfer(tempAmount);
		recipient.transfer(amount);
	}
}
// ====
// SMTEngine: chc
// ----
// Warning 9207: (133-151): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 9207: (167-185): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
