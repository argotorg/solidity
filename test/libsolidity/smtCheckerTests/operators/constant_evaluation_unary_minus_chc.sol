// SPDX-License-Identifier: GPL-3.0
pragma solidity *;
contract C {
    int256 constant signedConstant = 42;

    function testComptime() public pure {
        assert(-signedConstant == -42);
    }
}
// ====
// SMTEngine: chc
// ----
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
