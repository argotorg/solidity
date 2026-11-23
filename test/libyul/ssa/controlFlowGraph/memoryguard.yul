{
    let p := memoryguard(0x80)
    mstore(p, 42)
    let q := memoryguard(0x80)
    sstore(q, 1)
}
// ----
// memoryguard = 0x80
//
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = memoryguard
//     v1 = const 0x2a
//     builtin @mstore v0, v1
//     v3 = memoryguard
//     v4 = const 0x01
//     builtin @sstore v3, v4
//     main_exit
//
