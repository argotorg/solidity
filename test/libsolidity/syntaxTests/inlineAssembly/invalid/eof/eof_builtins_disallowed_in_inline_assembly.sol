// TODO: They should be available in some way in the context of inline assembly. For now it's disallowed them.
contract C {
    function f() view public {
        assembly {
            returncontract("a", 0)
            auxdataloadn(0)
        }
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// DeclarationError 4619: (186-200): Function "returncontract" not found.
// DeclarationError 4619: (221-233): Function "auxdataloadn" not found.
