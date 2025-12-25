uint8 constant k = 1;
bytes constant data = hex"ffff";

bytes32 constant sGlobal = sha256(hex"ffff");
bytes32 constant sConstArgGlobal = sha256(data);
address constant addrGlobal = ecrecover("1234", k, "0", abi.decode("", (bytes2)));
bytes20 constant ripemdGlobal = ripemd160(hex"ffff");
bytes20 constant ripemdConstArgGlobal = ripemd160(data);

contract A {
    bytes32 constant s = sha256(hex"ffff");
    bytes32 constant sConstArg = sha256(data);
    address constant addr = ecrecover("1234", k, "0", abi.decode("", (bytes2)));
    bytes20 constant ripemd = ripemd160(hex"ffff");
    bytes20 constant ripemdConstArg = ripemd160(data);
}
