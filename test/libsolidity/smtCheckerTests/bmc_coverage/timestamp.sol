contract C {
    function f() public view returns (uint) {
        uint b = block.timestamp;
        uint a = b + 0; // Overflow not possible!
        return a;
    }
}
// ====
// SMTEngine: bmc
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
