contract C {
    function f() public pure returns (uint) {
        return erc7201{gas: 10}("x");
    }
}
// ----
// TypeError 2193: (74-90): Function call options can only be set on external function calls or contract creations.
