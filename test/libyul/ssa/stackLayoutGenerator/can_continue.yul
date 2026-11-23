{
    // a function that can continue depending on condition
    function revert_wrapper(val, condition)
    {
        if iszero(condition)
        {
            revert(val, val)
        }
        // if we don't revert, we return nothing and the stack out should contain nothing but the return label
    }

    revert_wrapper(42, 1)
}
// ----
// object "object"
//     ; spilled: {}
// #0:
//     ; in: []
//     v0 = const 0x01
//     v1 = const 0x2a
//     ; [FunctionCallReturnLabel[0], lit0, lit1]
//     call @revert_wrapper v1, v0
//     ; out: []
//     main_exit
//
// func @revert_wrapper(args: (v0, v1)) -> 0 {
//     ; spilled: {}
// #0:
//     ; in: [ReturnLabel[1], v1, v0]
//     v0 = arg 0
//     v1 = arg 1
//     ; [ReturnLabel[1], v0, v1]
//     v2 = builtin @iszero v1
//     ; out: [ReturnLabel[1], v0, v2]
//     branch v2, #1, #2
// #1: preds: #0
//     ; in: [ReturnLabel[1], v0]
//     ; [ReturnLabel[1], v0, v0]
//     builtin @revert v0, v0
//     ; out: [ReturnLabel[1]]
//     terminated
// #2: preds: #0
//     ; in: [ReturnLabel[1], JUNK]
//     ; out: [ReturnLabel[1]]
//     return
// }
//
