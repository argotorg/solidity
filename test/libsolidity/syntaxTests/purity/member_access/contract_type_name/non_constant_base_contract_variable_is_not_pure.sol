contract B {
    uint vBase = 1;
}

contract D1 is B {
    uint256 constant vBaseCopy = B.vBase;
}

// ----
// TypeError 8349: (88-95): Initial value for constant variable has to be compile-time constant.
