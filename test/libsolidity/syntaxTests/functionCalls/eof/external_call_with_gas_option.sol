contract C {
    function g(bool x) public pure {
        require(x);
    }
    function f(bool x) public returns (uint) {
        this.g{gas: 8000}(x);
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// TypeError 3765: (131-148): Function call option "gas" cannot be used when compiling to EOF.
