pragma abicoder v2;
struct S {
    function(uint) external fn_uint;
}

contract C {
    S[] storageStruct;

    function test(S[] calldata calldataStruct) public returns (bool) {
        storageStruct = calldataStruct;

        assert(storageStruct.length == 2);
        assert(storageStruct[0].fn_uint.address == address(bytes20("01234567890123456789")));
        assert(storageStruct[0].fn_uint.selector == bytes4("abcd"));
        assert(storageStruct[1].fn_uint.address == address(bytes20("98765432109876543210")));
        assert(storageStruct[1].fn_uint.selector == bytes4("efgh"));
        return true;
    }
}
// ====
// compileViaYul: true
// ----
// test((function)[]): 0x20, 2, "01234567890123456789abcd", "98765432109876543210efgh" -> true
