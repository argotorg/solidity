contract A {
    uint x = msg.value;
    constructor() {
        assert(x == 0); // should hold
    }
}

contract B {
    constructor() payable {
        assert(msg.value == 0); // should fail
    }
}
// ====
// SMTEngine: bmc
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 4661: (154-176): BMC: Assertion violation happens here.
// Info 6002: BMC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
