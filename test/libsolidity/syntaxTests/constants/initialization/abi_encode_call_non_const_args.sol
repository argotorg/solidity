contract A {
    function f(uint a) external {}

    function getA() private view returns(uint) {
        return 1;
    }

    bytes constant fCallA = abi.encodeCall(A.f, (getA()));
}
// ----
// TypeError 8349: (151-180): Initial value for constant variable has to be compile-time constant.
