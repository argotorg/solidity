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
