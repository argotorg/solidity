pragma abicoder v2;
struct S {
    function(uint) external fn_uint;
}

contract C {
    S storageStruct;

    function test(S calldata calldataStruct) public returns (bool) {
        storageStruct = calldataStruct;
        return true;
    }
}
// ----
// test((function)): "01234567890123456789abcd" -> true
// test((function)): 0x3031323334353637383930313233343536373839616263640000000000000001 -> FAILURE
// test((function)): 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff -> FAILURE
