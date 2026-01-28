contract C {
    function foo() pure internal {
        address(10).delegatecall{value: 7, gas: 3}("");
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// TypeError 6189: (56-98): Cannot set option "value" for delegatecall.
// TypeError 3765: (56-98): Function call option "gas" cannot be used when compiling to EOF.
// Warning 9302: (56-102): Return value of low-level calls not used.
