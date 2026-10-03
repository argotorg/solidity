pragma abicoder v2;
struct S {
    function(uint) external fn_uint;
}

contract C {
    S storageStruct;

    function test(S calldata calldataStruct) public returns (bool) {
        storageStruct = calldataStruct;

        assert(storageStruct.fn_uint.address == address(bytes20("01234567890123456789")));
        assert(storageStruct.fn_uint.selector == bytes4("abcd"));
        return true;
    }
}
// ----
// test((function)): "01234567890123456789abcd" -> true
