contract Test {
    function loop() public pure {
        uint k = 0;
        while (k == 0 ? true : false) {
            ++k;
        }
    }
}
// ====
// SMTEngine: bmc
// SMTTargets: constantCondition
// ----
