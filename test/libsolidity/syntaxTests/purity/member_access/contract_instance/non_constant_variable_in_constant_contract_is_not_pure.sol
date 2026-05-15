contract C {
    uint256 public CONST_VAR = 0;
}

contract T {
    C constant c = C(address(1));
    uint256 constant constVarCopy = c.CONST_VAR();
}
// ----
// TypeError 8349: (133-146): Initial value for constant variable has to be compile-time constant.
