contract C
{
	function f(address payable a) public {
		require(1000 == address(this).balance);
		require(100 == a.balance);
		a.transfer(600);
		// a == this is not possible because address(this).balance == 1000
		// and a.balance == 100,
		// so this should hold in CHC, ignoring the transfer revert.
		assert(a.balance == 700);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 9207: (126-136): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
