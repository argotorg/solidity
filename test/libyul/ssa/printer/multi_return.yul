{
    function pair() -> a, b {
        a := 0x2222
        b := 0x3333
    }
    let x, y := pair()
    sstore(x, y)
}
// ----
// #0:
//     v0 = call @pair
//     v1 = proj v0, 0
//     v2 = proj v0, 1
//     builtin @sstore v1, v2
//     main_exit
//
// func @pair(args: ()) -> 2 {
// #0:
//     v0 = const 0x00
//     v1 = const 0x2222
//     v2 = const 0x3333
//     return v1, v2
// }
//
