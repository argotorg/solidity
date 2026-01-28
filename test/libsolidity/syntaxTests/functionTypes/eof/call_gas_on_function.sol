contract C {
    function (uint) external returns (uint) x;
    function f() public {
        x{gas: 2}(1);
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// TypeError 3765: (94-103): Function call option "gas" cannot be used when compiling to EOF.
