{
    function f(a, b) -> c {
        if mload(a) {
            a := add(a, 2)
            revert(a, a)
        }
        c := add(a, b)
    }
    mstore(42, f(0, 1))
}
// ----
// object "object"
//     ; spilled: {}
// #0:
//     ; in: []
//     v0 = const 0x01
//     v1 = const 0x00
//     ; [FunctionCallReturnLabel[0], lit0, lit1]
//     v2 = call @f v1, v0
//     v3 = const 0x2a
//     ; [v2, lit3]
//     builtin @mstore v3, v2
//     ; out: []
//     main_exit
//
// func @f(args: (v0, v1)) -> 1 {
//     ; spilled: {}
// #0:
//     ; in: [ReturnLabel[1], v1, v0]
//     v0 = arg 0
//     v1 = arg 1
//     v2 = const 0x00
//     ; [ReturnLabel[1], v1, v0, v0]
//     v3 = builtin @mload v0
//     v4 = const 0x02
//     ; out: [ReturnLabel[1], v1, v0, v3]
//     branch v3, #1, #2
// #1: preds: #0
//     ; in: [ReturnLabel[1], JUNK, v0]
//     ; [ReturnLabel[1], JUNK, lit4, v0]
//     v5 = builtin @add v0, v4
//     ; [ReturnLabel[1], JUNK, v5, v5]
//     builtin @revert v5, v5
//     ; out: [ReturnLabel[1], JUNK]
//     terminated
// #2: preds: #0
//     ; in: [ReturnLabel[1], v1, v0]
//     ; [ReturnLabel[1], v1, v0]
//     v16 = builtin @add v0, v1
//     ; out: [v16, ReturnLabel[1]]
//     return v16
// }
//
