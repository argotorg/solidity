pragma abicoder v2;
struct S {
    function(uint) external fn_uint;
    uint256[] arr;
}

contract C {
    S storageStruct;

    function test(S calldata calldataStruct) public returns (bool) {
        storageStruct = calldataStruct;

        assert(storageStruct.fn_uint.address == address(bytes20("01234567890123456789")));
        assert(storageStruct.fn_uint.selector == bytes4("abcd"));
        assert(storageStruct.arr.length == 3);
        assert(storageStruct.arr[0] == 11);
        assert(storageStruct.arr[1] == 22);
        assert(storageStruct.arr[2] == 33);
        return true;
    }
}
// ----
// test((function,uint256[])): 0x20, "01234567890123456789abcd", 0x40, 3, 11, 22, 33 -> true
// gas irOptimized: 134866
// gas legacy: 137443
// gas legacyOptimized: 135246
// gas ssaCFGOptimized: 134897
