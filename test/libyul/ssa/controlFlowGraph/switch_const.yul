{
    let x := calldataload(3)

    // this should yield calldataload(88) directly
    switch 1
    case 0 {
        x := calldataload(77)
    }
    case 1 {
        x := calldataload(88)
    }
    default {
        x := calldataload(99)
    }

    // this should yield the default case
    switch 55
    case 0 {
        x := calldataload(77)
    }
    case 1 {
        x := calldataload(88)
    }
    default {
        x := calldataload(99)
    }

    // this should be skipped entirely
    switch 66
    case 0 {
        x := calldataload(77)
    }
    case 1 {
        x := calldataload(88)
    }
    sstore(x, 0)
}
// ----
// #0:
//     ; dfs 0..0
//     ; live-in:
//     ; live-out:
//     ; used:
//     v0 = const 0x03
//     v1 = builtin @calldataload v0
//     v2 = const 0x01
//     v3 = const 0x00
//     v5 = const 0x4d
//     v8 = const 0x58
//     v10 = const 0x63
//     v12 = const 0x37
//     v18 = const 0x42
//     v9 = builtin @calldataload v8
//     v17 = builtin @calldataload v10
//     builtin @sstore v17, v3
//     main_exit
//
