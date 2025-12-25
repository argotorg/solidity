contract A {
    bool constant FLAG = true;
    function f(uint, bool) external {}
    bytes constant fCallA = abi.encodeCall(A.f, (123, FLAG));
}
