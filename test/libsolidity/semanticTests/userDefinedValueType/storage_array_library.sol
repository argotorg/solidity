// Used to cause ICE in signatureInExternalFunction.
type MyUint is uint;
type MyAddr is address;
type MyBytes1 is bytes1;

struct S { MyUint x; }

library L {
    function getArray(MyUint[] storage _a, uint _i) external view returns (MyUint) {
        return _a[_i];
    }
    function getNestedArray(MyUint[][] storage _a, uint _i, uint _j) external view returns (MyUint) {
        return _a[_i][_j];
    }
    function getMappingByValue(mapping(uint => MyAddr) storage _m, uint _k) external view returns (MyAddr) {
        return _m[_k];
    }
    function getMappingByKey(mapping(MyUint => uint) storage _m, MyUint _k) external view returns (uint) {
        return _m[_k];
    }
    function getStruct(S[] storage _s, uint _i) external view returns (MyUint) {
        return _s[_i].x;
    }
    function getBytes1Array(MyBytes1[] storage _a, uint _i) external view returns (MyBytes1) {
        return _a[_i];
    }
}

contract C {
    MyUint[] uintArr;
    MyUint[][] nestedArr;
    mapping(uint => MyAddr) addrMap;
    mapping(MyUint => uint) keyMap;
    S[] structArr;
    MyBytes1[] bytes1Arr;

    function testArray() public returns (uint) {
        uintArr.push(MyUint.wrap(42));
        return MyUint.unwrap(L.getArray(uintArr, 0));
    }
    function testNestedArray() public returns (uint) {
        nestedArr.push();
        nestedArr[0].push(MyUint.wrap(7));
        return MyUint.unwrap(L.getNestedArray(nestedArr, 0, 0));
    }
    function testMappingByValue() public returns (address) {
        addrMap[1] = MyAddr.wrap(address(0xBEEF));
        return MyAddr.unwrap(L.getMappingByValue(addrMap, 1));
    }
    function testMappingByKey() public returns (uint) {
        keyMap[MyUint.wrap(5)] = 123;
        return L.getMappingByKey(keyMap, MyUint.wrap(5));
    }
    function testStruct() public returns (uint) {
        structArr.push(S(MyUint.wrap(99)));
        return MyUint.unwrap(L.getStruct(structArr, 0));
    }
    function testBytes1Array() public returns (bytes1) {
        bytes1Arr.push(MyBytes1.wrap(0xab));
        return MyBytes1.unwrap(L.getBytes1Array(bytes1Arr, 0));
    }
}
// ----
// library: L
// testArray() -> 42
// testNestedArray() -> 7
// testMappingByValue() -> 0xbeef
// testMappingByKey() -> 123
// testStruct() -> 99
// testBytes1Array() -> 0xab00000000000000000000000000000000000000000000000000000000000000
