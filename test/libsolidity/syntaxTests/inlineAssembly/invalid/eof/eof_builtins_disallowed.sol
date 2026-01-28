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
// DeclarationError 7223: (75-84): Builtin function "eofcreate" is only available in EOF.
// DeclarationError 7223: (114-128): Builtin function "returncontract" is only available in EOF.
// DeclarationError 7223: (149-161): Builtin function "auxdataloadn" is only available in EOF.
