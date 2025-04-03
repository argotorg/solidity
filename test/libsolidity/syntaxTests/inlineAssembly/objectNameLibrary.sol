library Lib {}

contract C {
    function f() public {
        assembly {
            pop(eofcreate(Lib.objectName, 0, 0, 0, 0))
        }
    }
}
// ====
// bytecodeFormat: >=EOFv1
