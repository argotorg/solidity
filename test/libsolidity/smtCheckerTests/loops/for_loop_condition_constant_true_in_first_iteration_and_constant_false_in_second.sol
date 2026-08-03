contract Test {
    function loop() public pure {
        for (uint k = 0; (k == 0 ? true : false); k++) {
        }
    }
}
// ====
// SMTEngine: bmc
// SMTTargets: constantCondition
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
