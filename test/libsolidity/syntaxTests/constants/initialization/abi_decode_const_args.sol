bytes constant aEncoded = abi.encode(
    hex"aaaa"
);

contract A {
    bytes constant a = abi.decode(aEncoded, (bytes));
}
