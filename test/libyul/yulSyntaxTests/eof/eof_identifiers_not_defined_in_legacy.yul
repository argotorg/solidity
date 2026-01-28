{
    auxdataloadn(0)
    dataloadn(0)
    eofcreate("name", 0, 0, 0, 0)
    returncontract("name", 0, 0)
    rjump()
    rjumpi()
    callf(0)
    jumpf(0)
    retf()
    extcall(0, 1, 2, 3)
    extstaticcall(0, 1, 2)
    extdelegatecall(0, 1, 2)
    swapn()
    dupn()
}
// ====
// bytecodeFormat: legacy
// ----
// DeclarationError 7223: (6-18): Builtin function "auxdataloadn" is only available in EOF.
// DeclarationError 4619: (26-35): Function "dataloadn" not found.
// DeclarationError 7223: (43-52): Builtin function "eofcreate" is only available in EOF.
// DeclarationError 7223: (77-91): Builtin function "returncontract" is only available in EOF.
// DeclarationError 4619: (110-115): Function "rjump" not found.
// DeclarationError 4619: (122-128): Function "rjumpi" not found.
// DeclarationError 4619: (135-140): Function "callf" not found.
// DeclarationError 4619: (148-153): Function "jumpf" not found.
// DeclarationError 4619: (161-165): Function "retf" not found.
// TypeError 4328: (172-179): The "extcall" instruction is only available in EOF.
// TypeError 4328: (196-209): The "extstaticcall" instruction is only available in EOF.
// TypeError 4328: (223-238): The "extdelegatecall" instruction is only available in EOF.
// DeclarationError 4619: (252-257): Function "swapn" not found.
// DeclarationError 4619: (264-268): Function "dupn" not found.
