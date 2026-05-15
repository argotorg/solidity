==== Source: B.sol ====
function foo() pure returns(uint) { return 5; }
uint constant CONST_VALUE = 7;
bytes constant globalBytes = hex"123456";
bytes4 constant globalStaticBytes = hex"01020304";

==== Source: C.sol ====
import * as B from "B.sol";

contract C {
    function () pure returns(uint) constant private fooConstPtr = B.foo;

    function testFunctionPointer() pure public returns(uint) {
        return fooConstPtr();
    }

    function testGlobalVariable() pure public returns(uint) {
        return B.CONST_VALUE;
    }

    function testGlobalBytes() pure public returns(bytes memory) {
        return B.globalBytes;
    }

    function testGlobalStaticBytes() pure public returns(bytes4) {
        return B.globalStaticBytes;
    }
}
// ----
// testFunctionPointer() -> 5
// testGlobalVariable() -> 7
// testGlobalBytes() -> 0x20, 3, 0x1234560000000000000000000000000000000000000000000000000000000000
// testGlobalStaticBytes() -> 0x0102030400000000000000000000000000000000000000000000000000000000
