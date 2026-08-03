// SPDX-License-Identifier: GPL-3.0
pragma solidity *;
contract C {
    int256 constant signedConstant = 42;

    function testComptime() public pure {
        assert(-signedConstant == -42);
    }
}
// ====
// SMTEngine: bmc
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
