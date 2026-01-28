contract C {
    function foo() pure internal {
        address(10).staticcall{value: 7, gas: 3}("");
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// TypeError 2842: (56-96): Cannot set option "value" for staticcall.
// TypeError 3765: (56-96): Function call option "gas" cannot be used when compiling to EOF.
// Warning 9302: (56-100): Return value of low-level calls not used.
