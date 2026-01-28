// TODO: eofcreate, returncontract and auxdataloadn are for now disallowed in inline assembly. They need proper design on language level
contract C {
    function f() public {
        assembly {
            linkersymbol("x")
            memoryguard(0)
            verbatim_1i_1o(hex"600202", 0)

            pop(eofcreate("a", 0, 0, 0, 0))
            returncontract("a", 0, 0, 0)
            pop(auxdataloadn(0))

            pop(msize())
        }
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// SyntaxError 6553: (184-449): The msize instruction cannot be used when the Yul optimizer is activated because it can change its semantics. Either disable the Yul optimizer or do not use the instruction.
// DeclarationError 4619: (207-219): Function "linkersymbol" not found.
// DeclarationError 4619: (237-248): Function "memoryguard" not found.
// DeclarationError 4619: (264-278): Function "verbatim_1i_1o" not found.
// DeclarationError 4619: (312-321): Function "eofcreate" not found.
// TypeError 3950: (312-338): Expected expression to evaluate to one value, but got 0 values instead.
// DeclarationError 4619: (352-366): Function "returncontract" not found.
// DeclarationError 4619: (397-409): Function "auxdataloadn" not found.
// TypeError 3950: (397-412): Expected expression to evaluate to one value, but got 0 values instead.
