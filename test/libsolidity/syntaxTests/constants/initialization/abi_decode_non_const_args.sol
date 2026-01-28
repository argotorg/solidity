contract A {
    function encoded() private view returns (bytes memory) {
        return abi.encode(hex"aaaa");
    }

    bytes constant a = abi.decode(encoded(), (bytes));
}
// ----
// TypeError 8349: (142-172): Initial value for constant variable has to be compile-time constant.
