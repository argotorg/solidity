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
// bytecodeFormat: legacy
// ----
// TypeError 4328: (75-84): The "eofcreate" instruction is only available in EOF.
// DeclarationError 7223: (114-128): Builtin function "returncontract" is only available in EOF.
// DeclarationError 7223: (149-161): Builtin function "auxdataloadn" is only available in EOF.
