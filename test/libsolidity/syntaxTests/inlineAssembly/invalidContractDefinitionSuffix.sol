contract B {}

contract C {
    function f() public {
        B b;
        assembly {
            b := eofcreate(B.objectId, 0, 0, 0, 0)
        }
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// DeclarationError 8198: (113-123): Identifier "B.objectId" not found.
