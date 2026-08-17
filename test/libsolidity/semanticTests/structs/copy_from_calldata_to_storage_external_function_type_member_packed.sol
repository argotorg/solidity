pragma abicoder v2;
struct S {
    function(uint) external fn_uint;
    uint64 packed;
}

contract C {
    S storageStruct;

    function test(S calldata calldataStruct) public returns (bool) {
        storageStruct = calldataStruct;

        assert(storageStruct.fn_uint.address == address(bytes20("01234567890123456789")));
        assert(storageStruct.fn_uint.selector == bytes4("abcd"));
        assert(storageStruct.packed == 42);
        return true;
    }
}
// ----
// test((function,uint64)): "01234567890123456789abcd", 42 -> true
