{
    // TODO: The current implementation of YulOptimizerTests ignores subobjects that are not Data. It's impossbile to test
    // eofcreate and returncontract now.
    returndatacopy(1, 1, 0)
    calldatacopy(1, 1, 0)
    log0(1, 0)
    log1(1, 0, 1)
    log2(1, 0, 1, 1)
    log3(1, 0, 1, 1, 1)
    log4(1, 0, 1, 1, 1, 1)
    //pop(eofcreate("a", 1, 1, 1, 0))
    //returncontract("b", 1, 0)
    pop(extcall(1, 1, 1, 0))
    pop(extdelegatecall(1, 1, 0))
    pop(extstaticcall(1, 1, 0))
    return(1, 0)
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// step: loadResolver
//
// {
//     {
//         let _1 := 0
//         let _2 := 1
//         returndatacopy(0, _2, _1)
//         calldatacopy(0, _2, _1)
//         log0(0, _1)
//         log1(0, _1, _2)
//         log2(0, _1, _2, _2)
//         log3(0, _1, _2, _2, _2)
//         log4(0, _1, _2, _2, _2, _2)
//         pop(extcall(_2, _2, _2, _1))
//         pop(extdelegatecall(_2, 0, _1))
//         pop(extstaticcall(_2, 0, _1))
//         return(0, _1)
//     }
// }
