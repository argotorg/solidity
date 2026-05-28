{
    function f(a, b) -> r {
        r := add(a, b)
    }
    sstore(0, f(1, 2))
}
// ----
// #0:
//     v0 = const 0x02
//     v1 = const 0x01
//     v2 = call @f v1, v0
//     v3 = const 0x00
//     builtin @sstore v3, v2
//     main_exit
//
// func @f(args: (v0, v1)) -> 1 {
// #0:
//     v0 = arg 0
//     v1 = arg 1
//     v2 = const 0x00
//     v3 = builtin @add v0, v1
//     return v3
// }
//
