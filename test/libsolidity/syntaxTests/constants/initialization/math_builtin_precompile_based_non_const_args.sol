contract A {
    bytes data = hex"ffff";
    bytes32 constant sha = sha256(data);
    bytes20 constant ripemd = ripemd160(data);
    address constant addr = ecrecover("1234", 1, "0", abi.decode(data, (bytes2)));
}
// ----
// TypeError 8349: (68-80): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (112-127): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (157-210): Initial value for constant variable has to be compile-time constant.
