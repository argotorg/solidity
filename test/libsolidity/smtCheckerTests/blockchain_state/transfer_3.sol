contract C {
	address payable recipient;

	function shouldFail() public {
		recipient.transfer(1);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 9207: (76-94): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 8656: (76-97): CHC: Insufficient funds happens here.\nCounterexample:\nrecipient = 0x0\n\nTransaction trace:\nC.constructor()\nState: recipient = 0x0\nC.shouldFail()
