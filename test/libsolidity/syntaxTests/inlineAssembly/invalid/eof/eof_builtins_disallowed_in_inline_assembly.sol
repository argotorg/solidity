// TODO: They should be available in some way in the context of inline assembly. For now it's disallowed them.
contract C {
    function f() view public {
        assembly {
            eofcreate("a", 0, 0, 0, 0)
            returncontract("a", 0)
            auxdataloadn(0)
        }
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// DeclarationError 4619: (186-195): Function "eofcreate" not found.
// DeclarationError 4619: (225-239): Function "returncontract" not found.
// DeclarationError 4619: (260-272): Function "auxdataloadn" not found.
