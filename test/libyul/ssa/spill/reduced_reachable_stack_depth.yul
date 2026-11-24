// Six values are live at once, which spills two of them with a reach of 4 and none with the usual reach of 16.
{
    mstore(0x40, memoryguard(0x80))
    let a := calldataload(0)
    let b := calldataload(1)
    let c := calldataload(2)
    let d := calldataload(3)
    let e := calldataload(4)
    let f := calldataload(5)
    sstore(a, f)
    sstore(b, e)
    sstore(c, d)
    sstore(a, b)
}
// ====
// reachableStackDepth: 4
// ----
// object "object"
// ===== SSA CFG =====
// memoryguard = 0xc0
//
// #0:
//     v0 = memoryguard
//     v1 = const 0x40
//     builtin @mstore v1, v0
//     v3 = const 0x00
//     v4 = builtin @calldataload v3
//     v5 = const 0x01
//     v6 = builtin @calldataload v5
//     v7 = const 0x02
//     v8 = builtin @calldataload v7
//     v9 = const 0x03
//     v10 = builtin @calldataload v9
//     v11 = const 0x04
//     v12 = builtin @calldataload v11
//     v13 = const 0x05
//     v14 = builtin @calldataload v13
//     builtin @sstore v4, v14
//     builtin @sstore v6, v12
//     builtin @sstore v8, v10
//     builtin @sstore v4, v6
//     main_exit
//
// ===== spill info =====
// CFG[0] <main>
//   spilled:
//     v12 -> mem 0x80
//     v14 -> mem 0xa0
//   mstore schedule:
//     mstore addr(v12) <- v12 (B#0)
//     mstore addr(v14) <- v14 (B#0)
