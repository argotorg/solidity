{
    let x := calldataload(3)
    sstore(0, x)
}
// ----
// #0:
//     v0 = const 0x03
//     v1 = builtin @calldataload v0
//     v2 = const 0x00
//     builtin @sstore v2, v1
//     main_exit
//
