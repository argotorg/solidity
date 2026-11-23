{
    function pair(a) -> x, y {
        x := add(a, 1)
        y := add(a, 2)
    }
    let p, q := pair(42)
    let r, s := pair(p)
    sstore(q, add(r, s))
}
// ----
// object "object"
//     ; spilled: {}
// #0:
//     ; in: []
//     v0 = const 0x2a
//     ; [FunctionCallReturnLabel[0], lit0]
//     v1 = call @pair v0
//     v2 = proj v1, 0
//     v3 = proj v1, 1
//     ; [v3, FunctionCallReturnLabel[1], v2]
//     v4 = call @pair v2
//     v5 = proj v4, 0
//     v6 = proj v4, 1
//     ; [v3, v6, v5]
//     v7 = builtin @add v5, v6
//     ; [v7, v3]
//     builtin @sstore v3, v7
//     ; out: []
//     main_exit
//
// func @pair(args: (v0)) -> 2 {
//     ; spilled: {}
// #0:
//     ; in: [ReturnLabel[1], v0]
//     v0 = arg 0
//     v1 = const 0x00
//     v2 = const 0x01
//     ; [ReturnLabel[1], v0, lit2, v0]
//     v3 = builtin @add v0, v2
//     v4 = const 0x02
//     ; [ReturnLabel[1], v3, lit4, v0]
//     v5 = builtin @add v0, v4
//     ; out: [v3, v5, ReturnLabel[1]]
//     return v3, v5
// }
//
