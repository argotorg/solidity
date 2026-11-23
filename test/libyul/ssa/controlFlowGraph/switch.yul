{
    let x := calldataload(3)

    switch sload(0)
    case 0 {
        x := calldataload(77)
    }
    case 1 {
        x := calldataload(88)
    }
    default {
        x := calldataload(99)
    }
    sstore(x, 0)
}
// ----
// #0:
//     ; dfs 0..5
//     ; live-in:
//     ; live-out: v3[1]
//     ; used:
//     v0 = const 0x03
//     v1 = builtin @calldataload v0
//     v2 = const 0x00
//     v3 = builtin @sload v2
//     v4 = builtin @eq v3, v2
//     v5 = const 0x4d
//     v7 = const 0x01
//     v9 = const 0x58
//     v11 = const 0x63
//     branch v4, #2, #3
// #1: preds: #2, #4, #5
//     ; dfs 2..2
//     ; live-in: phi13[2]
//     ; live-out:
//     ; used: phi13[2]
//     v13 = phi
//     builtin @sstore v13, v2
//     main_exit
// #2: preds: #0
//     ; dfs 1..2
//     ; live-in:
//     ; live-out: v6[1]
//     ; used:
//     v6 = builtin @calldataload v5
//     upsilon v6 -> ^v13
//     jump #1
// #3: preds: #0
//     ; dfs 3..5
//     ; live-in: v3[1]
//     ; live-out:
//     ; used: v3[1]
//     v8 = builtin @eq v3, v7
//     branch v8, #4, #5
// #4: preds: #3
//     ; dfs 4..4
//     ; live-in:
//     ; live-out: v10[1]
//     ; used:
//     v10 = builtin @calldataload v9
//     upsilon v10 -> ^v13
//     jump #1
// #5: preds: #3
//     ; dfs 5..5
//     ; live-in:
//     ; live-out: v12[1]
//     ; used:
//     v12 = builtin @calldataload v11
//     upsilon v12 -> ^v13
//     jump #1
//
