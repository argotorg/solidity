{
    let free := memoryguard(0x80)
    mstore(free, 0x42)
    sstore(0, mload(free))
}
// ----
// memoryguard = 0x80
//
// #0:
//     v0 = memoryguard
//     v1 = const 0x42
//     builtin @mstore v0, v1
//     v3 = builtin @mload v0
//     v4 = const 0x00
//     builtin @sstore v4, v3
//     main_exit
//
