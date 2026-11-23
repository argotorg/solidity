{
    let x := calldataload(3)
    // this should not appear in the output at all
    if 0 {
        x := calldataload(77)
    }
    // this should avoid a conditional jump
    if 33 {
        x := calldataload(42)
    }
    let y := calldataload(x)
    sstore(y, 0)
}
// ----
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = const 0x03
//     v1 = builtin @calldataload v0
//     v2 = const 0x00
//     v3 = const 0x4d
//     v5 = const 0x21
//     v6 = const 0x2a
//     v7 = builtin @calldataload v6
//     v14 = builtin @calldataload v7
//     builtin @sstore v14, v2
//     main_exit
//
