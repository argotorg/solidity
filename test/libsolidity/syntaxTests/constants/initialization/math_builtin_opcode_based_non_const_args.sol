contract A {
    uint256 k = 7;
    uint256 constant amod = addmod(1, 8, k);
    uint256 constant mmod = mulmod(1, 8, k);

    bytes data = hex"ffff";
    bytes32 constant keccak = keccak256(data);
}
// ----
// TypeError 8349: (60-75): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (105-120): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (181-196): Initial value for constant variable has to be compile-time constant.
