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
// bytecodeFormat: legacy
// ----
// TypeError 4328: (103-112): The "eofcreate" instruction is only available in EOF.
// TypeError 1342: (113-125): ".objectName" suffix is supported only for contract name identifier when compiling to EOF.
// DeclarationError 8678: (98-138): Variable count for assignment to "b" does not match number of values (1 vs. 0)
