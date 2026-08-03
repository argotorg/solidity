contract MockContract {
	bytes4 public constant SENTINEL_ANY_MOCKS = hex"01";

	constructor() {
		assert(SENTINEL_ANY_MOCKS >= 0);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
