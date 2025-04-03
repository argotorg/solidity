contract B {}

contract C {
    function f() public {
        B b;
        assembly {
            b := eofcreate(B.objectName, 0, 0, 0, 0)
        }
    }
}
// ====
// bytecodeFormat: >=EOFv1
