{
    function sum(n) -> s {
        if n {
            s := add(n, sum(sub(n, 1)))
        }
    }
    mstore(0, sum(10))
}
// ----
// object "object"
//     ; spilled: {}
// #0:
//     ; in: []
//     v0 = const 0x0a
//     ; [FunctionCallReturnLabel[0], lit0]
//     v1 = call @sum v0
//     v2 = const 0x00
//     ; [v1, lit2]
//     builtin @mstore v2, v1
//     ; out: []
//     main_exit
//
// func @sum(args: (v0)) -> 1 {
//     ; spilled: {}
// #0:
//     ; in: [ReturnLabel[1], v0]
//     v0 = arg 0
//     v1 = const 0x00
//     v2 = const 0x01
//     ; out: [ReturnLabel[1], v0, v0]
//     branch v0, #1, #3
// #1: preds: #0
//     ; in: [ReturnLabel[1], v0]
//     ; [ReturnLabel[1], v0, lit2, v0]
//     v3 = builtin @sub v0, v2
//     ; [ReturnLabel[1], v0, FunctionCallReturnLabel[0], v3]
//     v4 = call @sum v3
//     ; [ReturnLabel[1], v4, v0]
//     v5 = builtin @add v0, v4
//     upsilon v5 -> ^v6
//     ; out: [ReturnLabel[1], v5]
//     jump #2
// #2: preds: #3, #1
//     ; in: [ReturnLabel[1], phi6]
//     v6 = phi
//     ; out: [phi6, ReturnLabel[1]]
//     return v6
// #3: preds: #0
//     ; in: [ReturnLabel[1], JUNK]
//     upsilon v1 -> ^v6
//     ; out: [ReturnLabel[1], JUNK]
//     jump #2
// }
//
