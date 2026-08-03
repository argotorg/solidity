contract C {
	address owner;

	constructor() {
		owner = msg.sender;
		assert(owner >= address(0)); // should hold
	}
}

contract D {
	address owner;

	constructor() {
		unchecked {
			owner = msg.sender;
			assert(owner >= address(0)); // should hold
		}
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
