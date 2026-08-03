// SPDX-License-Identifier: GPL-3.0


// Regression for handling signedness, see issues #14791 and #14792
contract C {
    mapping(bool => int240) internal v1;
    mapping(bytes14 => bytes15) internal v;

    function f() public payable {
        delete v["A"];
    }
}
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
